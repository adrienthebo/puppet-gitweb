# Class: gitweb
#   Installs gitweb and configures apache to server it.
# Parameters:
#
# Actions:
#
# Requires:
#   - apache
#   - gitweb::settings
# Sample Usage:
#   include gitweb
class gitweb($site_alias, $doc_root, $project_root, $projects_list) {

  package { "gitweb":
    ensure  => present,
  }

  file { "/etc/gitweb.conf":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "0644",
    content => template("gitweb/gitweb.conf.erb"),
    require => Package["gitweb"],
  }

  file { $doc_root:
    ensure => directory,
    owner  => 'git', # XXX,
    group  => 'git', # XXX,
    source => 'puppet:///modules/gitweb/html',
  }

  apache::vhost::redirect { $site_alias:
    port  => "80",
    dest  => "https://${site_alias}",
  }

  apache::vhost { "${site_alias}_ssl":
    priority      => "10",
    port          => "443",
    ssl           => true,
    docroot       => $doc_root,
    template      => "gitweb/apache-gitweb.conf.erb",
  }
}
