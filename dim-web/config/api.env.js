'use strict';

module.exports = {
  DIM_LOGIN: process.env.DIM_LOGIN,
  DIM_RPC: process.env.DIM_RPC,
  LOGIN: process.env.LOGIN,
  LOGOUT: process.env.LOGOUT,
  PAGE_SIZES: [10, 25, 50],
  SLEEP: process.env.SLEEP,
  POPULAR_ZONES: [
    {
      'name': 'server.lan',
      'views': []
    },
    {
      'name': 'schlund.de',
      'views': []
    }
  ],
  DEFAULT_LAYER3DOMAIN: 'default',
  RR_TYPES: [
    'A',
    'AAAA',
    'PTR',
    'CNAME',
    'MX',
    'NS',
    'SRV',
    'TXT',
    'SPF',
    'RP',
    'CERT',
    'HINFO',
    'NAPTR'
  ],
  // Available validation: after, alpha, alpha_dash, alpha_num, alpha_spaces, before, between, confirmed, credit_card,
  // date_between, date_format, decimal, digits, dimensions, email, ext, image, in, ip, max, max_value, mimes, min,
  // min_value, not_in, numeric, regex, required, size, url
  // See http://vee-validate.logaretm.com/rules.html
  RR_FIELDS_BY_TYPE: {
    A: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'IP',
        name: 'ip',
        validation: 'ip|required'
      }
    ],
    AAAA: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'IP',
        name: 'ip',
        validation: 'required'
      }
    ],
    PTR: [
      {
        label: 'IP',
        name: 'ip',
        validation: 'ip|required'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'PTRD name',
        name: 'ptrdname',
        validation: 'required|max:65535'
      }
    ],
    CNAME: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'CNAME',
        name: 'cname',
        validation: 'required|max:65535'
      }
    ],
    MX: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'Preference',
        name: 'preference',
        validation: 'numeric|required'
      },
      {
        label: 'Exchange',
        name: 'exchange',
        validation: 'required|max:65535'
      }
    ],
    NS: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'NSD name',
        name: 'nsdname',
        validation: 'required|max:65535'
      }
    ],
    SRV: [
      {
        label: 'Record',
        name: 'name',
        validation: 'required|max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'Priority',
        name: 'priority',
        validation: 'required|numeric'
      },
      {
        label: 'Weight',
        name: 'weight',
        validation: 'required|numeric'
      },
      {
        label: 'Port',
        name: 'port',
        validation: 'required|numeric'
      },
      {
        label: 'Target',
        name: 'target',
        validation: 'required|max:65535'
      }
    ],
    TXT: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'max:10|required'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'Strings',
        name: 'strings',
        validation: 'required|max:65535'
      }
    ],
    SPF: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'required|max:10'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'Strings',
        name: 'strings',
        validation: 'required|max:65535'
      }
    ],
    RP: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'required|max:10'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'Mbox',
        name: 'mbox',
        validation: 'required|max:65535'
      },
      {
        label: 'TXT dname',
        name: 'txtdname',
        validation: 'required|max:65535'
      }
    ],
    CERT: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'required|max:10'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'Certificate type',
        name: 'certificate_type',
        validation: 'required|numeric'
      },
      {
        label: 'Key tag',
        name: 'key_tag',
        validation: 'required|numeric'
      },
      {
        label: 'Algorithm',
        name: 'algorithm',
        validation: 'required|numeric'
      },
      {
        label: 'Certificate',
        name: 'certificate',
        validation: 'required||max:65535'
      }
    ],
    HINFO: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'required|max:10'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'CPU',
        name: 'cpu',
        validation: 'required|max:65535'
      },
      {
        label: 'OS',
        name: 'os',
        validation: 'required|max:65535'
      }
    ],
    NAPTR: [
      {
        label: 'Record',
        name: 'name',
        validation: 'max:255'
      },
      {
        label: 'TTL',
        name: 'ttl',
        validation: 'numeric'
      },
      {
        label: 'Type',
        name: 'type',
        validation: 'required|max:10'
      },
      {
        label: 'Views',
        name: 'views',
        validation: 'max:255'
      },
      {
        label: 'Order',
        name: 'order',
        validation: 'required|numeric'
      },
      {
        label: 'Preference',
        name: 'preference',
        validation: 'required|numeric'
      },
      {
        label: 'Flags',
        name: 'flags',
        validation: 'required|max:65535'
      },
      {
        label: 'Service',
        name: 'service',
        validation: 'required|max:65535'
      },
      {
        label: 'Regexp',
        name: 'regexp',
        validation: 'required|max:65535'
      },
      {
        label: 'Replacement',
        name: 'replacement',
        validation: 'required|max:65535'
      }
    ]
  }
};
