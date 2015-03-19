(defvar bike-lang-keywords '("var" "def" "class" "if" "let" "else" "true" "false" "nil" "while" "unless" "apply" "extends" "import" "into" "package" "with" "mixin" "hash" "private" "elseif" "for" "of") )
(defvar bike-lang-constants '("E" "Pi" "Phi" "Sqrt2" "SqrtE" "SqrtPi" "SqrtPhi" "Ln2" "Log2E" "Ln10" "Log10E"))

(defvar bike-mode-hook nil)

(defvar bike-mode-map
  (let ((bike-mode-map (make-keymap)))
    (define-key bike-mode-map "\C-j" 'newline-and-indent)
    bike-mode-map)
  "Keymap for Bike major mode")

(add-to-list 'auto-mode-alist '("\\.bk\\'" . bike-mode))

(defconst bike-font-lock-keywords
  (list
   `(,(regexp-opt bike-lang-keywords t) . font-lock-keyword-face)
   `(,(regexp-opt bike-lang-constants t) . font-lock-constant-face)
   '("\\('\\w*'\\)" . font-lock-variable-name-face))
  "Minimal highlighting expressions for WPDL mode")
