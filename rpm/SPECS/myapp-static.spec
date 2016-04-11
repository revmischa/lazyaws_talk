Summary: Static file webserver
Name: myapp-static
Version: 1.0
Release: 1
License: ABRMS
Source0: myapp-static-nginx.conf
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Requires: nginx myapp-static-files

%description
Sets up nginx to serve static files from disk. Copies myapp-static.conf.

%prep
rm -rf $RPM_BUILD_ROOT

%build
mkdir -p $RPM_BUILD_ROOT/etc/nginx/conf.d
cp %{SOURCE0} $RPM_BUILD_ROOT/etc/nginx/conf.d/myapp-static.conf

%install

%post
/sbin/service nginx start >/dev/null 2>&1
/sbin/chkconfig nginx on

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service nginx stop >/dev/null 2>&1
    /sbin/chkconfig --del nginx
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(-,root,root)
/etc/nginx/conf.d/myapp-static.conf

%changelog
* Wed Mar  5 2014  <mish@ip-10-3-1-41> - static-1
- Initial build.

