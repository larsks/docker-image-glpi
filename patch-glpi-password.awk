BEGIN {target = 0 }

/^]/ {target=0}

target == 0 {print}

$1 == "$tables['glpi_users']" {target=1}

target == 1 {
  print "   ["
  print "      'id'         => '2',"
  print "      'name'       => 'glpi',"
  printf "      'password'   => '%s',\n", PASSWORD
  print "      'language'   => null,"
  print "      'list_limit' => '20',"
  print "      'authtype'   => '1',"
  print "   ],"

  target = 2
}
