activate_this = '/opt/dim/bin/activate_this.py'
execfile(activate_this, dict(__file__=activate_this))

from dim import create_app
application = create_app()
