import copy
import os
import shlex
import sys
import textwrap
from functools import wraps


def bash_quote(w, quote):
    '''
    Quote word *w* with quote character *quote* which may be empty, single quote or double quote.
    '''
    assert quote in ('', '"', "'")
    if quote == "'":
        w = w.replace("'", quote + '"\'"' + quote)
    else:
        # some characters are special and cannot be escaped unless we use a single quote:
        # ! - get rid of history expansion
        # \x01 - breaks escaping in bash: echo "\\$" -> \\$
        # \n - when only using escapes
        special_characters = '!\x01'
        if quote == '':
            special_characters += '\n'
        for special in special_characters:
            if special in w:
                return ("'" + special + "'").join(bash_quote(s, quote) for s in w.split(special))

        # escape characters
        escaped_chars = set()
        if quote == '':
            escaped_chars |= set(os.environ.get("COMP_WORDBREAKS", " \t\"'@><=;|&(:."))
            escaped_chars |= set("`$\"'\t ~&;?|#()*{><[")
        elif quote == '"':
            escaped_chars |= set("`$\"")
        escaped = ''
        last = ''
        for i, c in enumerate(w):
            if last == '\\' and (c in escaped_chars | set('\n\\') or quote == ''):
                escaped += '\\'
            if (c == '\\' and i == len(w) - 1) or (c in escaped_chars):
                escaped += '\\'
            escaped += c
            last = c
        w = escaped
    return quote + w + quote


class Namespace(dict):
    def __getattr__(self, key):
        return self[key]

    def __setattr__(self, key, value):
        self[key] = value

    def __deepcopy__(self, memo):
        return copy.deepcopy(dict(self), memo)


class Parser(object):
    def __init__(self, tokens, complete_token=None):
        '''
        :param complete_token: the token to be completed; `None` disables completion
        '''
        self.tokens = tokens
        self.complete_token = complete_token
        # internal state
        self.long = {}
        self.short = {}
        self.pos = 0
        # results
        self._completions = []
        self.values = Namespace()
        self.errors = []
        self.subcommands = []

    def get_state(self):
        return dict([(attr, copy.copy(getattr(self, attr)))
                     for attr in ('long', 'short', 'pos', '_completions', 'errors', 'subcommands')] +
                    [('values', Namespace(copy.deepcopy(self.values)))])

    def set_state(self, state):
        for attr, val in state.items():
            setattr(self, attr, val)

    def add_options(self, options):
        for opt in options:
            if opt.short:
                self.short[opt.short] = opt
            if opt.long:
                self.long[opt.long] = opt

    def error(self, error):
        self.errors.append(error)

    def __repr__(self):
        return "<Parser values=%r, errors=%r, subcommands=%r>" % (self.values, self.errors, self.subcommands)

    @property
    def token(self):
        return self.tokens[self.pos] if self.pos < len(self.tokens) else None

    @property
    def last_token(self):
        return self.tokens[self.pos - 1] if self.pos - 1 >= 0 else None

    def token_is_option(self):
        return self.token.startswith('-')

    def eat_token(self):
        token = self.token
        self.pos += 1
        return token

    def barf_token(self):
        self.pos -= 1

    def parse_options(self):
        while self.token and self.token_is_option():
            option = None
            token = self.eat_token()
            if token.startswith('--'):
                if token[2:] in self.long:
                    option = self.long[token[2:]]
            elif token[1:] in self.short:
                option = self.short[token[1:]]
            if option is None:
                self.error('Unknown option %s' % token)
                return
            else:
                option.parse(self)
        if self._completing_option:
            self._add_completions('-' + k for k in list(self.short.keys()))
            self._add_completions('--' + k for k in list(self.long.keys()))

    def parse_arguments(self, arguments):
        for arg in arguments:
            if arg.nargs not in (None, '?', '*', '+'):
                raise Exception('Invalid nargs %s' % arg.nargs)
            self._add_arg_completions(arg)
            self.parse_options()
            if arg.nargs in (None, '+'):
                arg.parse(self)
                self.parse_options()
            if arg.nargs in ('?', '*', '+'):
                rewind_state = None
                while self.token and (not arg.choices or self.token in arg.choices):
                    if type(arg.stop_at) != list and self.token == arg.stop_at:
                        rewind_state = self.get_state()
                    elif type(arg.stop_at) == list and self.token in arg.stop_at:
                        rewind_state = self.get_state()
                    arg.parse(self)
                    self.parse_options()
                    if arg.nargs == '?':
                        break
                if rewind_state:
                    self.set_state(rewind_state)
                if arg.nargs in ('*', '+'):
                    # Even if the token doesn't match the set of choices, it
                    # might still yield valid completions for the current arg
                    self._add_arg_completions(arg)
            if self.errors:
                return
        self.parse_options()

    @property
    def completing(self):
        return not self.errors and self.token is None and self.complete_token is not None

    @property
    def _completing_option(self):
        return self.completing and len(self.complete_token) > 0 and self.complete_token[0] == '-'

    @property
    def _completing_argument(self):
        return self.completing and (len(self.complete_token) == 0 or self.complete_token[0] != '-')

    def _add_completions(self, completions):
        self._completions.extend(c for c in completions if c.startswith(self.complete_token))

    def _add_arg_completions(self, arg):
        if self._completing_argument:
            self._add_completions(arg.completions(self.complete_token, self))


class Option(object):
    def __init__(self, short, long, action='store_true', dest=None, help=None, default=None):
        '''
        The number of additional tokens needed for an Option is determined by
        *action*:

        - ``store_true`` requires 0 tokens and stores True in *dest*
        - ``store`` requires 1 token and stores it in *dest**
        '''
        self.short = short
        self.long = long
        self.dest = dest if dest else long
        self.help = help
        self.action = action
        self.default = default

    def __repr__(self):
        return '-%s/--%s' % (self.short, self.long)

    def set_default(self, parser):
        parser.values[self.dest] = self.default

    def parse(self, parser):
        if self.action == 'store_true':
            parser.values[self.dest] = True
        elif self.action == 'store':
            if parser.token is None or parser.token_is_option():
                parser.error("%s expects an argument" % parser.last_token)
            else:
                value = parser.eat_token()
                parser.values[self.dest] = value


class ArgMixin(object):
    def usage(self):
        if self.nargs is None:
            return self.metavar
        elif self.nargs == '?':
            return '[%s]' % self.metavar
        elif self.nargs == '*':
            return '[%s]...' % self.metavar
        elif self.nargs == '+':
            return '%s...' % self.metavar
        else:
            raise Exception('Invalid nargs %s' % self.nargs)

    def __repr__(self):
        return self.metavar

    def set_default(self, parser):
        '''
        Sets the default value for the curent argument. Called as soon as the argument's command is seen.
        '''
        pass

    def completions(self, complete_token, parser):
        '''
        Returns the completions matching `complete_token` for the current state from `parser`.
        '''
        pass

    def parse(self, parser):
        '''
        Uses the state from `parser` to consume the tokens for the current arg
        (only one instance, even if nargs says otherwise).  Called only if at
        least a token is required for the current argument.
        '''
        pass


class Argument(ArgMixin):
    def __init__(self, name, dest=None, metavar=None, nargs=None, action='store', choices=None,
                 default=None, completions=None, stop_at=None):
        self.name = name
        self.dest = dest if dest else name
        if metavar:
            self.metavar = metavar
        elif choices:
            self.metavar = '|'.join(choices)
        else:
            self.metavar = name.upper()
        self.nargs = nargs
        self.action = action
        self.choices = choices
        self.completion_fn = completions
        self.default = default
        # stop_at is an ugly hack to resolve grammar ambiguity
        # The parser will revert to the state for the last instance of this token
        self.stop_at = stop_at

    def set_default(self, parser):
        if self.action in ('append', 'append_unique') or self.nargs in ('*', '+'):
            parser.values.setdefault(self.dest, [])
        elif self.action == 'store':
            parser.values.setdefault(self.dest, self.default)
        else:
            pass

    def completions(self, complete_token, parser):
        if self.choices:
            if self.action == 'append_unique':
                return set(self.choices) - set(parser.values[self.dest])
            else:
                return self.choices
        elif hasattr(self, 'completion_fn') and callable(self.completion_fn):
            comps = self.completion_fn(complete_token, parser)
            if self.action == 'append_unique':
                return set(comps) - set(parser.values[self.dest])
            return comps
        else:
            return []

    def parse(self, parser):
        token = parser.eat_token()
        if token is None:
            parser.error("A value is required for %s" % self.metavar)
            return
        if self.choices and token not in self.choices:
            parser.error("%s must be one of: %s" % (self.metavar, ' '.join(self.choices)))
            return

        if self.action == 'append' or self.nargs in ('*', '+'):
            parser.values[self.dest].append(token)
        elif self.action == 'store':
            parser.values[self.dest] = token
        elif self.action == 'append_unique':
            pv = parser.values[self.dest]
            if token in pv:
                parser.error('%s cannot be specified twice' % token)
            else:
                pv.append(token)
        elif self.action is None:
            pass
        else:
            raise Exception('Invalid action %s' % self.action)


class Token(Argument):
    def __init__(self, name, dest=None, nargs=None, action=None):
        super(Token, self).__init__(name, metavar=name, choices=(name, ), action=action, nargs=nargs)
        if dest is None:
            self.dest = None


class Group(ArgMixin):
    '''
    If the group has nargs='?' or nargs='*' and it's not followed by eof it must
    start with a static set of choices (otherwise the grammar would be
    ambiguous).
    '''
    def __init__(self, *args, **kwargs):
        self.nargs = kwargs.pop('nargs', None)
        self.stop_at = kwargs.pop('stop_at', None)
        self.arguments = args

    @property
    def metavar(self):
        return ' '.join(a.usage() for a in self.arguments)

    @property
    def choices(self):
        return self.arguments[0].choices

    def completions(self, complete_token, parser):
        return self.arguments[0].completions(complete_token, parser)

    def parse(self, parser):
        parser.parse_arguments(self.arguments)

    def set_default(self, parser):
        for arg in self.arguments:
            arg.set_default(parser)


class Command(object):
    def __init__(self, name, *args, **kwargs):
        self.name = name
        self.options = []
        self.subcommands = []
        self.arguments = []
        for o in args:
            if isinstance(o, Option):
                self.options.append(o)
            elif isinstance(o, Command):
                self.subcommands.append(o)
            else:
                self.arguments.append(o)
        self.help = kwargs.pop('help', None)
        self.description = kwargs.pop('description', None)
        self.defaults = kwargs.pop('defaults', {})
        self.default_subcommand = kwargs.pop('default_subcommand', None)
        assert not kwargs

    def register(self, *args, **kwargs):
        def decorator(func):
            cmd, path = self._get_scmd_path(args[0])
            if 'description' not in kwargs and func.__doc__:
                kwargs['description'] = textwrap.dedent(func.__doc__).strip()
            kwargs.setdefault('defaults', {}).setdefault('run', func)
            cmd.subcommands.append(Command(path[-1], *(args[1:]), **kwargs))

            @wraps(func)
            def wrapper(*wargs, **wkwargs):
                func(*wargs, **wkwargs)
            return wrapper
        return decorator

    def alias(self, source_path, dest_path):
        scmd, spath = self._get_scmd_path(source_path)
        dcmd, dpath = self._get_scmd_path(dest_path)
        dest_cmd = copy.copy(scmd._get_subcommand(spath[-1]))
        dest_cmd.name = dpath[-1]
        dcmd.subcommands.append(dest_cmd)

    def set_default(self, parser):
        parser.values.update(self.defaults)
        for arg in self.arguments:
            arg.set_default(parser)
        for opt in self.options:
            opt.set_default(parser)

    def parse(self, tokens):
        parser = Parser(tokens)
        self._parse_command(parser)
        if parser.token:
            parser.error('Unparsed tokens: %s' % ' '.join(parser.tokens[parser.pos:]))
        return parser

    def complete(self, line, point):
        # ignore everything after point
        line = line[:point]
        # if the line ends in an incomplete escape sequence skip it
        if line[-1] == '\\' and line[-2] != '\\':
            line = line[:-1]
        quote_char = ''
        for attempt in range(2):
            try:
                lex = shlex.shlex(line, posix=True)
                lex.whitespace_split = True
                tokens = list(lex)
            except ValueError:
                if attempt == 0:
                    # close the quotes and try again
                    quote_char = lex.state
                    line += quote_char
                else:
                    raise
        tokens = tokens[1:]  # skip the program name
        if tokens and (line[-1] != ' ' or line[-2:] == r'\ '):
            complete_token = tokens.pop()
        else:
            complete_token = ''
        parser = Parser(tokens, complete_token)
        self._parse_command(parser)
        return set(bash_quote(c, quote_char) for c in parser._completions)

    def handle_shell_completion(self):
        if 'COMP_LINE' in os.environ:
            for c in self.complete(os.environ['COMP_LINE'], int(os.environ['COMP_POINT'])):
                print(c)
            sys.exit()

    def usage(self):
        return ' '.join([self.name] + [a.usage() for a in self.arguments])

    def chain_usage(self, chain):
        return ' '.join(c.usage() for c in chain)

    def print_help(self, subcommands):
        '''Only works for the top-level command'''
        last = self
        chain = [self]
        for cmd_name in subcommands:
            last = last._get_subcommand(cmd_name)
            if last is None:
                print("Unknown subcommand: %s" % cmd_name)
                return
            chain.append(last)

        usage = self.chain_usage(chain)
        if last.subcommands:
            if last.default_subcommand:
                usage += ' [<subcommand>]'
            else:
                usage += ' <subcommand>'
        print("Usage: {}".format(usage))
        if last.description or last.help:
            print("\n", last.description or last.help)

        def _cmd_chains(cmd, stop_on_args=False):
            '''Follows subcommand chains until an argument can be specified'''
            if not cmd.subcommands or (cmd.arguments and stop_on_args):
                return {'': cmd}
            else:
                return dict(((s.name + ' ' + name).strip(), cmd)
                            for s in cmd.subcommands
                            for name, cmd in _cmd_chains(s, True).items())
        if last.subcommands:
            print("\nSubcommands:")
            if last.default_subcommand:
                cmd = last._get_subcommand(last.default_subcommand)
                print("  %-20s %s" % ('[%s]' % cmd.name, cmd.help or cmd.name))
            for name, cmd in sorted(_cmd_chains(last).items()):
                if not last.default_subcommand or last.default_subcommand != name:
                    print("  %-20s %s" % (name, cmd.help or name))

        for i, cmd in enumerate(reversed(chain)):
            if cmd.options:
                print("\nOptions for %s:" % ' '.join(c.name for c in chain[:len(chain) - i]))
                wrapper = textwrap.TextWrapper(width=80,
                                               initial_indent=' ' * 26,
                                               subsequent_indent=' ' * 26)
                for opt in sorted(cmd.options, key=lambda x: x.long or x.short):
                    print("  %-2s %-20s %s" % ('-' + opt.short if opt.short else '',
                                               '--' + opt.long if opt.long else '',
                                               wrapper.fill(opt.help or '').lstrip()))

    def _get_subcommand(self, subcommand):
        for cmd in self.subcommands:
            if cmd.name == subcommand:
                return cmd
        else:
            return None

    def _get_scmd_path(self, path_string):
        path = path_string.split()
        cmd = self
        for cname in path[:-1]:
            cmd = cmd._get_subcommand(cname)
            if cmd is None:
                raise Exception('Invalid command path: %s (%s not found)' % (path_string, cname))
        return cmd, path

    def _parse_command(self, parser):
        self.set_default(parser)
        parser.add_options(self.options)
        parser.parse_arguments(self.arguments)
        if self.subcommands:
            if parser._completing_argument:
                parser._add_completions(s.name for s in self.subcommands)
            token = parser.eat_token()
            if token is None:
                if self.default_subcommand:
                    self._get_subcommand(self.default_subcommand).set_default(parser)
                else:
                    parser.error("Subcommand expected")
            else:
                cmd = self._get_subcommand(token.lower())
                if cmd:
                    parser.subcommands.append(cmd.name)
                    cmd._parse_command(parser)
                elif self.default_subcommand:
                    parser.barf_token()
                    cmd = self._get_subcommand(self.default_subcommand)
                    cmd._parse_command(parser)
                else:
                    parser.error("Invalid subcommand %s" % token)



