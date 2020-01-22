package com.verisignlabs.dnssec.cl;

import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

import org.apache.commons.cli.AlreadySelectedException;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.commons.cli.UnrecognizedOptionException;

import com.verisignlabs.dnssec.security.DnsKeyAlgorithm;

/**
 * This is a base class for jdnssec command line tools. Each command line tool
 * should inherit from this class, create a subclass of CLIStateBase (overriding
 * setupOptions and processOptions), and implement the execute() method.
 * Subclasses also have their own main() methods, which should just create the
 * subclass variant of the CLIState and call run().
 */
public abstract class CLBase
{
  protected static Logger log;

  /**
   * This is a very simple log formatter that simply outputs the log level and
   * log string.
   */
  public static class BareLogFormatter extends Formatter
  {
    @Override
    public String format(LogRecord arg0)
    {
      StringBuilder out = new StringBuilder();
      String lvl = arg0.getLevel().getName();

      out.append(lvl);
      out.append(": ");
      out.append(arg0.getMessage());
      out.append("\n");

      return out.toString();
    }
  }

  /**
   * This is a base class for command line parsing state. Subclasses should
   * override setupOptions and processOptions.
   */
  public static class CLIStateBase
  {
    protected Options opts;
    protected String  usageStr;

    /**
     * The base constructor. This will setup the command line options.
     * 
     * @param usage
     *          The command line usage string (e.g.,
     *          "jdnssec-foo [..options..] zonefile")
     */
    public CLIStateBase(String usage)
    {
      usageStr = usage;
      setup();
    }

    /** This is the base set of command line options provided to all subclasses. */
    private void setup()
    {
      // Set up the standard set of options that all jdnssec command line tools will implement.
      opts = new Options();

      // boolean options
      opts.addOption("h", "help", false, "Print this message.");
      opts.addOption("m", "multiline", false,
                     "Output DNS records using 'multiline' format");

      OptionBuilder.hasOptionalArg();
      OptionBuilder.withLongOpt("verbose");
      OptionBuilder.withArgName("level");
      OptionBuilder.withDescription("verbosity level -- 0 is silence, 3 is info, "
          + "5 is debug information, 6 is trace information. default is level 2 (warning)");
      opts.addOption(OptionBuilder.create('v'));

      OptionBuilder.hasArg();
      OptionBuilder.withArgName("alias:original:mnemonic");
      OptionBuilder.withLongOpt("alg-alias");
      OptionBuilder.withDescription("Define an alias for an algorithm");
      opts.addOption(OptionBuilder.create('A'));

      setupOptions(opts);
    }

    /**
     * This is an overridable method for subclasses to add their own command
     * line options.
     * 
     * @param opts
     *          the options object to add (via OptionBuilder, typically) new
     *          options to.
     */
    protected void setupOptions(Options opts)
    {
      // Subclasses generally override this.
    }

    /**
     * This is the main method for parsing the command line arguments.
     * Subclasses generally override processOptions() rather than this method.
     * This method create the parsing objects and processes the standard
     * options.
     * 
     * @param args
     *          The command line arguments.
     * @throws ParseException
     */
    public void parseCommandLine(String args[]) throws ParseException
    {
      CommandLineParser cli_parser = new PosixParser();
      CommandLine cli = cli_parser.parse(opts, args);

      if (cli.hasOption('h')) usage();

      Logger rootLogger = Logger.getLogger("");
      int value = parseInt(cli.getOptionValue('v'), -1);

      switch (value)
      {
        case 0:
          rootLogger.setLevel(Level.OFF);
          break;
        case 1:
          rootLogger.setLevel(Level.SEVERE);
          break;
        case 2:
        default:
          rootLogger.setLevel(Level.WARNING);
          break;
        case 3:
          rootLogger.setLevel(Level.INFO);
          break;
        case 4:
          rootLogger.setLevel(Level.CONFIG);
        case 5:
          rootLogger.setLevel(Level.FINE);
          break;
        case 6:
          rootLogger.setLevel(Level.ALL);
          break;
      }

      // I hate java.util.logging, btw.
      for (Handler h : rootLogger.getHandlers())
      {
        h.setLevel(rootLogger.getLevel());
        h.setFormatter(new BareLogFormatter());
      }

      if (cli.hasOption('m'))
      {
        org.xbill.DNS.Options.set("multiline");
      }

      String[] optstrs = null;
      if ((optstrs = cli.getOptionValues('A')) != null)
      {
        for (int i = 0; i < optstrs.length; i++)
        {
          addArgAlias(optstrs[i]);
        }
      }

      processOptions(cli);
    }

    /**
     * Process additional tool-specific options. Subclasses generally override
     * this.
     * 
     * @param cli
     *          The {@link CommandLine} object containing the parsed command
     *          line state.
     */
    protected void processOptions(CommandLine cli) throws ParseException
    {
      // Subclasses generally override this.
    }

    /** Print out the usage and help statements, then quit. */
    public void usage()
    {
      HelpFormatter f = new HelpFormatter();

      PrintWriter out = new PrintWriter(System.err);

      // print our own usage statement:
      f.printHelp(out, 75, usageStr, null, opts, HelpFormatter.DEFAULT_LEFT_PAD,
                  HelpFormatter.DEFAULT_DESC_PAD, null);

      out.flush();
      System.exit(64);

    }

    protected void addArgAlias(String s)
    {
      if (s == null) return;

      DnsKeyAlgorithm algs = DnsKeyAlgorithm.getInstance();

      String[] v = s.split(":");
      if (v.length < 2) return;

      int alias = parseInt(v[0], -1);
      if (alias <= 0) return;
      int orig = parseInt(v[1], -1);
      if (orig <= 0) return;
      String mn = null;
      if (v.length > 2) mn = v[2];

      algs.addAlias(alias, mn, orig);
    }
  }

  public static int parseInt(String s, int def)
  {
    try
    {
      int v = Integer.parseInt(s);
      return v;
    }
    catch (NumberFormatException e)
    {
      return def;
    }
  }

  /**
   * Calculate a date/time from a command line time/offset duration string.
   * 
   * @param start
   *          the start time to calculate offsets from.
   * @param duration
   *          the time/offset string to parse.
   * @return the calculated time.
   */
  public static Date convertDuration(Date start, String duration) throws ParseException
  {
    if (start == null) start = new Date();
    if (duration.startsWith("now"))
    {
      start = new Date();
      if (duration.indexOf("+") < 0) return start;

      duration = duration.substring(3);
    }

    if (duration.startsWith("+"))
    {
      long offset = (long) parseInt(duration.substring(1), 0) * 1000;
      return new Date(start.getTime() + offset);
    }

    SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyyMMddHHmmss");
    dateFormatter.setTimeZone(TimeZone.getTimeZone("GMT"));
    try
    {
      return dateFormatter.parse(duration);
    }
    catch (java.text.ParseException e)
    {
      throw new ParseException(e.getMessage());
    }
  }

  public abstract void execute() throws Exception;

  public void run(CLIStateBase state, String[] args)
  {
    try
    {
      state.parseCommandLine(args);
    }
    catch (UnrecognizedOptionException e)
    {
      System.err.println("error: unknown option encountered: " + e.getMessage());
      state.usage();
    }
    catch (AlreadySelectedException e)
    {
      System.err.println("error: mutually exclusive options have "
          + "been selected:\n     " + e.getMessage());
      state.usage();
    }
    catch (Exception e)
    {
      System.err.println("error: unknown command line parsing exception:");
      e.printStackTrace();
      state.usage();
    }

    log = Logger.getLogger(this.getClass().toString());

    try
    {
      execute();
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
}
