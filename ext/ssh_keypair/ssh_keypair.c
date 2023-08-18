#include <ssh_keypair.h>

static VALUE ssh_keypair_initialize(VALUE self) {
  ssh_key key;
  char *b64_key;

  rb_iv_set(self, "@ssh_key_type", rb_str_new2("ssh-ed25519"));

  if (ssh_pki_generate(SSH_KEYTYPE_ED25519, 0, &key) != SSH_OK) {
    rb_raise(rb_eRuntimeError, "Unable to generate SSH keys");
    return self;
  }

  if (ssh_pki_export_privkey_base64(key, NULL, NULL, NULL, &b64_key) != SSH_OK) {
    ssh_key_free(key);
    rb_raise(rb_eRuntimeError, "Unable to export private key");
    return self;
  }

  rb_iv_set(self, "@private_key", rb_str_new_cstr(b64_key));
  free(b64_key);

  if (ssh_pki_export_pubkey_base64(key, &b64_key) != SSH_OK) {
    ssh_key_free(key);
    rb_raise(rb_eRuntimeError, "Unable to export public key");
    return self;
  }

  rb_iv_set(self, "@public_key", rb_str_new_cstr(b64_key));
  free(b64_key);
  ssh_key_free(key);

  return self;
}

void Init_ssh_keypair(void) {
  VALUE mCapistrano = rb_define_module("Capistrano");
  VALUE mEc2InstanceConnect = rb_define_module_under(mCapistrano, "Ec2InstanceConnect");
  VALUE cKeypair = rb_define_class_under(mEc2InstanceConnect, "SshKeypair", rb_cObject);

  rb_define_method(cKeypair, "initialize", ssh_keypair_initialize, 0);
  rb_define_attr(cKeypair, "ssh_key_type", 1, 0);
  rb_define_attr(cKeypair, "private_key", 1, 0);
  rb_define_attr(cKeypair, "public_key", 1, 0);
}
