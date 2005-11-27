#!/usr/bin/perl -w

use strict;

use Module::Build;

Module::Build->new(
	module_name => 'Term::VT102::Boundless',
	license => 'perl',
	requires => {
		'perl'				=> '5.8',
	},
	build_requires => {
		'Test::More' => "0.53",
		'Term::VT102' => 0,
	},
	create_makefile_pl => 'traditional',
	sign => 1,
)->create_build_script;

