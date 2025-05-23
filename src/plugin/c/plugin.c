int fallback_editor_requested = 0;

int rl_fun__fallback_editor(int count, int key)
{
  fallback_editor_requested = 1;

  rl_done = 1; // tell readline to close

  return 0;
}

// (argument not used, but Liberty doesn't call external functions
// which don't receive arguments)
void my_readline_init(int i)
{
  // set program name, so that the user can define
  // olme-specific Readline settings
  rl_readline_name = "olme";

  // define a named function and set up default key binding
  rl_add_defun("fallback-editor", &rl_fun__fallback_editor, -1);
  rl_bind_keyseq("\\C-b", &rl_fun__fallback_editor);
}

// (argument not used, dtto)
int is_fallback_requested(int i)
{
  return fallback_editor_requested;
}
