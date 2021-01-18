import * as components from './components';

export default [
  {
    path: '/',
    component: components.ZonesListView,
    name: 'zones-list'
  },
  {
    path: '/zone/:zone_name/view/:view_name',
    component: components.ZoneView,
    name: 'zone'
  },
  {
    path: '/search/:pattern',
    component: components.ZoneSearchView,
    name: 'zones-search'
  }
];
