Summary: Configuration for a stage instance
Name: myapp-cfg-stage
Version: 1.0
Release: 1
License: ABRMS
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Provides: myapp-cfg

%define DBUSER ec2-user

%description

%prep
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

%install
mkdir -p $RPM_BUILD_ROOT/myapp/app
cp $RPM_SOURCE_DIR/../../config/stage/mw_local.yml $RPM_BUILD_ROOT/myapp/config/ # or whatever

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(-, ec2-user, ec2-user) /myapp/app/mw_local.yml

%changelog
* Fri Jun 06 2014  <mish@rockridge> - base
- Initial build.

