import { routes as dnsZones } from './dns-zones';
import { routes as ipPools } from './ip-pools';
import { routes as ipSpace } from './ip-space';
import NotFound from './NotFound';

export default [
  ...dnsZones,
  ...ipPools,
  ...ipSpace,
  {path: '*', component: NotFound}
];
