CAS login middleware
====================

Instalation 
-----------------

1. Install virtualenv, pip:

```bash
    apt-get install python-virtualenv python-pip python2.7-dev
```

2. Create a virtual env and install dependencies:

```bash
    virtualenv dimvenv --python=python2.6 --no-site-packages
    source venv/bin/activate
    pip install -r requirements.txt
```

3. Copy and update config.py:
```bash
    cp ./config.py.example config.py
    nano config.py
```

Development
-----------

1. Start the development server:

```bash
  FLASK_APP=login.py python2 -m flask run [--port=5000] [--host=127.0.0.1]
```

2. For HTTPS debugging, enable serving over ssl by adding `app.run()` to `login.py` in order to pass SSL context:

```python
    if __name__ == "__main__":
      app.run(ssl_context='adhoc', port=443, host='127.0.0.1')
```

```bash
  # run app
  python2 -m login.py
```
