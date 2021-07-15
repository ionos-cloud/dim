Name:       pdns-output
Version:    4.0.0
Release:    1
Summary:    DIM PDNS Output Service
License:    MIT
URL:        https://github.com/1and1/dim
Requires:   java-1.8.0-openjdk-headless
BuildRequires:   java-1.8.0-openjdk-devel

Source0: dim-%{version}.tar.gz
Source1: pdns-output.properties
Source2: pdns-output.service

%define debug_package %{nil}

%description
Connects to DIM Database and reads configuration of outputs and events for PowerDNS Databases.

%prep
%setup -q -n dim-%{version}

%build
pushd jdnssec-dnsjava
ls
ls ..
../gradlew build -x test
../gradlew publishToMavenLocal
popd
pushd jdnssec-tools
../gradlew build -x test
../gradlew publishToMavenLocal
popd
pushd gmp-rsa
../gradlew build -x test
../gradlew publishToMavenLocal
popd
pushd pdns-output
../gradlew build -x test
../gradlew publishToMavenLocal
popd

%install
install -Dm 644 pdns-output/build/libs/pdns-output-4.0.0-all.jar %{buildroot}%{_libexecdir}/pdns-output.jar
install -Dm 644 %{SOURCE1} %{buildroot}%{_sysconfdir}/dim/pdns-output.properties
install -Dm 644 %{SOURCE2} %{buildroot}%{_unitdir}/pdns-output.service

%files
%{_libexecdir}/pdns-output.jar
%{_sysconfdir}/dim/pdns-output.properties
%{_unitdir}/pdns-output.service

%changelog
* Thu Jul 15 2021 Christoph Maser <christoph.maser@gmail.com> - 4.0.0
- Initial package
