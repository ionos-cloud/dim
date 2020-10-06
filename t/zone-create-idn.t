# see also rfc5890

# this is dömäin.example
$ ndcli create zone xn--dmin-moa0i.example
WARNING - Creating zone xn--dmin-moa0i.example without profile
WARNING - Primary NS for this Domain is now localhost.

# this is موقع.وزارة-الاتصالات.مصر
$ ndcli create zone xn--4gbrim.xn----ymcbaaajlc6dj7bxne2c.xn--wgbh1c
WARNING - Creating zone xn--4gbrim.xn----ymcbaaajlc6dj7bxne2c.xn--wgbh1c without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli delete zone xn--dmin-moa0i.example
$ ndcli delete zone xn--4gbrim.xn----ymcbaaajlc6dj7bxne2c.xn--wgbh1c
