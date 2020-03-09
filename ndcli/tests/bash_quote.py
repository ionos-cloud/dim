import subprocess

import hypothesis.strategies as st
from dimcli.cliparse import bash_quote
from hypothesis import given, settings, assume


@given(st.text(alphabet=''.join(chr(a) for a in range(1, 128))),
       st.sampled_from(('', "'", '"')))
@settings(max_examples=50000)
def test(s, quote):
    assume(not s.startswith('-'))
    s = str(s)
    quoted = bash_quote(s, quote)
    command = 'echo -n ' + quoted
    out = subprocess.check_output(['bash', '-c', command])
    assert out == s
