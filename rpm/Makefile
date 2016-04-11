REPODIR=repo
REPOARCHS=x86_64 noarch
NOARCH=RPMS/noarch

.PHONY: all archs $(REPOARCHS) base app sync clean repo repoprep yum-s3-iam configs

usage:
	echo "Please specify: dev, qa, stage, prod"

# build and push to repos
push-base: all-rpms
dev: push-base sync-dev
qa: push-base sync-qa
stage: push-base sync-stage
prod: push-base sync-prod

# build everything
all-rpms: rpmprep base logger static configs yum-s3-iam

# rpm builds:
base: rpmprep
	rpmbuild -bb SPECS/myapp-base.spec
logger: rpmprep
	rpmbuild -bb SPECS/myapp-papertrail.spec
static: rpmprep
	rpmbuild -bb SPECS/myapp-static.spec
configs: rpmprep
	rpmbuild -bb SPECS/myapp-cfg-dev.spec
	rpmbuild -bb SPECS/myapp-cfg-qa.spec
	rpmbuild -bb SPECS/myapp-cfg-stage.spec
	rpmbuild -bb SPECS/myapp-cfg-prod.spec

# build S3 IAM yum repo plugin
yum-s3-iam: SOURCES/yum-s3-iam
	$(MAKE) -C SOURCES/yum-s3-iam rpm
SOURCES/yum-s3-iam:
	git clone git@github.com:revmischa/yum-s3-iam.git SOURCES/yum-s3-iam

# create yum repo
repoprep: base cleanrepos
	mkdir -p $(REPODIR)
	cp -r RPMS/* $(REPODIR)
repo: archs yum-s3-iam
archs: repoprep $(REPOARCHS)
$(REPOARCHS):
	$(foreach dir,$(REPOARCHS), mkdir -p $(REPODIR)/$(dir);)
	$(foreach dir,$(REPOARCHS), createrepo $(REPODIR)/$(dir);)
rpmprep: rpmbuild-env
rpmbuild-env:
	mkdir -p {BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}

# sync repos to S3
S3PUT=s3put --region us-west-2 -c 4
sync-yum-plugin:
	$(S3PUT) --bucket myapp-pub --prefix $(NOARCH) --key_prefix provision $(NOARCH)/yum-plugin-s3-iam-1.0-2.noarch.rpm  # public s3 yum IAM plugin
sync-dev: sync-yum-plugin sumologic-download-rpm repo 
	$(S3PUT) --bucket myapp-yum --prefix $(REPODIR) --key_prefix repo/dev $(REPODIR)  # private
sync-qa: sync-yum-plugin sumologic-download-rpm repo
	$(S3PUT) --bucket myapp-yum --prefix $(REPODIR) --key_prefix repo/qa $(REPODIR)  # private
sync-stage: sync-yum-plugin sumologic-download-rpm repo
	$(S3PUT) --bucket myapp-yum --prefix $(REPODIR) --key_prefix repo/stage $(REPODIR)  # private
sync-prod: sync-yum-plugin sumologic-download-rpm repo
	$(S3PUT) --bucket myapp-yum --prefix $(REPODIR) --key_prefix repo/prod $(REPODIR)  # private

clean-app:
	rm -f RPMS/*/myapp-app*.rpm
cleanrepos:
	rm -rf $(REPODIR)
clean: cleanrepos
	rm -rf {S,}RPMS/*
	rm -rf BUILD/*