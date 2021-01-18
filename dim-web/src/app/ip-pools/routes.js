import * as components from './components';

export default [
  {
    path: '/ip-pools',
    name: 'pools-list',
    component: components.IpPoolsListView
  },
  {
    path: '/ip-pools/search/:pattern',
    name: 'pools-search',
    component: components.IpPoolsSearchView
  },
  {
    path: '/ip-pool/:pool_name',
    name: 'pool',
    component: components.IpPoolView
  }
];
