int fallback_editor_requested = 0;
char *initial_content = NULL;

/**
 * Used as a Readline named command.
 *
 * Function signature specification:
 * https://tiswww.cwru.edu/php/chet/readline/readline.html#Custom-Functions
 */
int rl_fun__fallback_editor(int count, int key)
{
  fallback_editor_requested = 1;

  rl_done = 1; // tell readline to close

  return 0;
}

/**
 * Readline startup hook.
 * Sets initial content of the input field.
 */
int rl_hook__set_initial_content()
{
  if (initial_content) {
    rl_insert_text(initial_content);
    rl_startup_hook = NULL;
  }

  return 0;
}

/**
 * Custom Readline initialization.
 */
void my_readline_init(char *first_line)
{
  // set program name, so that the user can define
  // olme-specific Readline settings
  rl_readline_name = "olme";

  // define a named function and set up default key binding
  rl_add_defun("fallback-editor", rl_fun__fallback_editor, -1);
  rl_bind_keyseq("\\C-b", rl_fun__fallback_editor);

  if (first_line != NULL) {
    initial_content = first_line;
    rl_startup_hook = rl_hook__set_initial_content;
  }
}

/**
 * Predicate: did the user request the fallback editor?
 *
 * (argument not used, but Liberty doesn't call external functions
 * which don't receive arguments:
 * https://savannah.gnu.org/bugs/index.php?67160 )
 */
int is_fallback_requested(int i)
{
  return fallback_editor_requested;
}
