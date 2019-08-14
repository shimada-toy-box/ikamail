class LdapUser < ActiveLdap::Base
  ldap_mapping dn_attribute: configurations['ldap']['user_dn'],
               prefix: configurations['ldap']['user_base'],
               classes: configurations['ldap']['user_classes']
  belongs_to :primary_group,
             class_name: 'LdapGroup',
             foreign_key: 'gidNumber',
             primary_key: 'gidNumber'
  belongs_to :groups,
             many: 'memberUid'
end