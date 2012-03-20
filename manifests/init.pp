# Class: gitweb
#   Installs gitweb and configures apache to serve it.
# Parameters:
#
# Actions:
#
# Requires:
#   - apache
#   - gitweb::settings
# Sample Usage:
#   include gitweb
class gitweb($site_alias, $doc_root, $project_root, $projects_list, $ssl = true) {

  file { "/etc/gitweb.conf":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "0644",
    content => template("gitweb/gitweb.conf.erb"),
  }

  file { $doc_root:
    ensure  => directory,
    owner   => 'git', # XXX,
    group   => 'git', # XXX,
    source  => 'puppet:///modules/gitweb/html',
    recurse => true,
  }

  # Ensure that cgi script is executable
  file { "${doc_root}/index.cgi":
    ensure  => file,
    owner   => 'git', # XXX,
    group   => 'git', # XXX,
    mode    => '0755',
    source  => 'puppet:///modules/gitweb/html/index.cgi',
  }

  if $ssl == true {
    # Listen on port 443 and enable SSL redirection

    apache::vhost::redirect { $site_alias:
      port  => "80",
      dest  => "https://${site_alias}",
    }

    $apache_port = '443'
  }
  else {
    $apache_port = '80'
  }

  include apache::mod::suexec
  include apache::mod::rewrite
  apache::vhost { $site_alias:
    priority => "10",
    port     => $apache_port,
    ssl      => $ssl,
    docroot  => $doc_root,
    template => "gitweb/apache-gitweb.conf.erb",
    require  => [
      Class['apache::mod::rewrite'],
      Class['apache::mod::suexec'],
    ],
  }
}
