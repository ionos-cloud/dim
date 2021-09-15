## DIM PDNS Output Service

Connects to DIM Database and reads configuration of outputs and events for PowerDNS Databases.

Can apply DNSSec Zone signing.

# Build

```bash
cd <dim-checkout>
cd jdnssec-dnsjava && ../gradlew build -x test && ../gradlew publishToMavenLocal; cd ..
cd jdnssec-tools && ../gradlew build -x test && ../gradlew publishToMavenLocal; cd ..
cd gmp-rsa && ../gradlew build -x test && ../gradlew publishToMavenLocal; cd ..
cd pdns-output && ../gradlew shadowJar -x test; cd ..
```

`pdns-output-<version>-all.jar` is now in `<dim-checkout>/pdns-output/build/libs`.

RPM Packaging, systemd unit file and other stuff will follow.
