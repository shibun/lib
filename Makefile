#
#  Author: Hari Sekhon
#  Date: 2013-01-06 15:45:00 +0000 (Sun, 06 Jan 2013)
#

# Library dependencies are handled in one place in calling project

ifdef TRAVIS
	SUDO2 =
else
	SUDO2 = sudo
endif

# EUID /  UID not exported in Make
# USER not populated in Docker
ifeq '$(shell id -u)' '0'
	SUDO =
	SUDO2 =
else
	SUDO = sudo
endif

.PHONY: make
make:
	[ -x /usr/bin/apt-get ] && make apt-packages
	[ -x /usr/bin/yum ]     && make yum-packages

	git update-index --assume-unchanged resources/custom_tlds.txt

	# order here is important, in Travis and some stripped down client some deps are not pulled in automatically but are required for subsequent module builds
	yes "" | $(SUDO2) cpan App::cpanminus
	yes "" | $(SUDO2) cpanm --notest \
		YAML \
		Data::Dumper \
		Devel::Cover::Report::Coveralls \
		ExtUtils::Constant \
		IO::Socket::IP \
		IO::Socket::Timeout \
		JSON \
		JSON::XS \
		LWP::Simple \
		LWP::UserAgent \
		Math::Round \
		MongoDB \
		MongoDB::MongoClient \
		Net::LDAP \
		Net::LDAPI \
		Net::LDAPS \
		Net::DNS \
		Net::SSH::Expect \
		Net::SSL \
		Redis \
		Readonly \
		Readonly::XS \
		Term::ReadKey \
		Thrift \
		Time::HiRes \
		XML::SAX \
		XML::Simple \
		;

.PHONY: apt-packages
apt-packages:
	$(SUDO) apt-get install -y gcc
	# needed to fetch the library submodule at end of build
	$(SUDO) apt-get install -y build-essential libwww-perl git
	# for DBD::mysql as well as headers to build DBD::mysql if building from CPAN
	$(SUDO) apt-get install -y libdbd-mysql-perl libmysqlclient-dev
	# needed to build XML::Simple dep XML::Parser
	$(SUDO) apt-get install -y libexpat1-dev

.PHONY: yum-packages
yum-packages:
	rpm -q gcc perl-CPAN perl-libwww-perl git || $(SUDO) yum install -y gcc perl-CPAN perl-libwww-perl git
	# for DBD::mysql as well as headers to build DBD::mysql if building from CPAN
	rpm -q perl-DBD-MySQL mysql-devel || $(SUDO) yum install -y perl-DBD-MySQL mysql-devel
	# needed to build XML::Simple dep XML::Parser
	rpm -q expat-devel || $(SUDO) yum install -y expat-devel

.PHONY: test
test:
	PERL5LIB=$(PERLBREW_ROOT) PERL5OPT=-MDevel::Cover=-coverage,statement,branch,condition,path,subroutine prove -lrsv --timer t

.PHONY: install
install:
	@echo "No installation needed, just add '$(PWD)' to your \$$PATH"

.PHONY: update
update:
	git pull
	make

.PHONY: update
update2:
	git pull

tld:
	wget -O resources/tlds-alpha-by-domain.txt http://data.iana.org/TLD/tlds-alpha-by-domain.txt
