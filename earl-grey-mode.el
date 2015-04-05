
(load "earl-data.el")


;;;;;;;;;;;;;;;;;;;
;; CUSTOMIZATION ;;
;;;;;;;;;;;;;;;;;;;

;;;###autoload
(defgroup earl nil
  "Customization group for the Earl Grey programming language."
  :group 'languages)

;; ;;;###autoload
;; (defcustom earl-use-codec
;;   ;; Unicode works weird in emacs 22 and earlier, so we default to t
;;   ;; only if the version is recent enough. Users can override this.
;;   earl-emacs-recent-enough
;;   "*Use the earl codec when starting the earl-mode?"
;;   :type 'boolean :group 'earl)

;;;###autoload
(defcustom earl-indent
  3
  "*Number of spaces to indent with"
  :type 'integer :group 'earl)

;;;###autoload
(defcustom earl-definition-constructors
  '("class")
  "*Keywords starting definitions."
  :type '(repeat string) :group 'earl)

;;;###autoload
(defcustom earl-major-constructors
  '("if" "then" "else", "match"
    "for" "while"
    "chain", "do", "blocktest")
  "*Keywords starting important control structures."
  :type '(repeat string) :group 'earl)

;;;###autoload
(defcustom earl-special-constants
  '("true" "false" "null", "undefined")
  "*Special constants."
  :type '(repeat string) :group 'earl)


;;;;;;;;;;;
;; FACES ;;
;;;;;;;;;;;

;;;###autoload
(defgroup earl-faces nil
  "Faces used to highlight the Earl Grey language."
  :group 'earl)

(defun earl-stock-face (light dark &optional bold)
  (if bold
      `((((class color) (background light))
         (:foreground ,light :weight bold))
        (((class color) (background dark))
         (:foreground ,dark :weight bold))
        (t
         (:foreground "black" :background "white" :weight bold)))
    `((((class color) (background light))
       (:foreground ,light))
      (((class color) (background dark))
       (:foreground ,dark))
      (t
       (:foreground "black" :background "white")))))

;; Constructor faces

(defface earl-font-lock-constructor
  (earl-stock-face "black" "white" t)
  "Face for control structures ('a' in 'a b: c')."
  :group 'earl-faces)

(defface earl-font-lock-major-constructor
  (earl-stock-face "purple" "cyan" t)
  "Face for major control structures like if, else, for, etc."
  :group 'earl-faces)

(defface earl-font-lock-special-constant
  (earl-stock-face "dark cyan" "magenta")
  "Face for special constants."
  :group 'earl-faces)

(defface earl-font-lock-definition
  (earl-stock-face "dark green" "green")
  "Face for definitions, e.g. the color of 'f' in 'def f[x]: ...'"
  :group 'earl-faces)

;; Operator faces

(defface earl-font-lock-wordop
  (earl-stock-face "black" "white" t)
  "Face for operators that are words (each with etc.)"
  :group 'earl-faces)

(defface earl-font-lock-op
  (earl-stock-face "blue" "light blue")
  "Face for category 3 operators (+ - * / % etc.)"
  :group 'earl-faces)

;; (defface earl-font-lock-c4op
;;   (earl-stock-face "dark blue" "deep sky blue")
;;   "Face for category 4 operators (← :: ∧ ∨ etc.)"
;;   :group 'earl-faces)

;; Token faces

(defface earl-font-lock-variable
  (earl-stock-face "black" "white")
  "Face for variable names"
  :group 'earl-faces)

(defface earl-font-lock-symbol
  (earl-stock-face "dark red" "red")
  "Face for tokens like .x"
  :group 'earl-faces)

(defface earl-font-lock-prefix
  (earl-stock-face "dark blue" "blue")
  "Face for tokens like #x"
  :group 'earl-faces)

(defface earl-font-lock-suffix
  (earl-stock-face "black" "white")
  "Face for tokens like x? or x!"
  :group 'earl-faces)

(defface earl-font-lock-number
  (earl-stock-face "dark cyan" "dark cyan")
  "Face for numeric tokens"
  :group 'earl-faces)

;; Bracket face

(defface earl-font-lock-bracket
  (earl-stock-face "black" "white" t)
  "Face for brackets () [] {}"
  :group 'earl-faces)

;; Special faces

(defface earl-font-lock-assignment
  (earl-stock-face "goldenrod4" "goldenrod1")
  "Face for variable assignment, i.e. 'a' in 'a ← x'"
  :group 'earl-faces)

(defface earl-font-lock-interpolation
  (earl-stock-face "goldenrod4" "goldenrod1")
  "Face for variable interpolation inside strings"
  :group 'earl-faces)

;; Error faces

(defface earl-font-lock-warning
  (earl-stock-face "red" "red" t)
  "Face warning for potentially invalid constructs"
  :group 'earl-faces)

(defface earl-font-lock-invalid
  `((((class color))
     (:foreground "white" :background "red" :weight bold))
    (t
     (:foreground "white" :background "black" :weight bold)))
  "Face for invalid characters"
  :group 'earl-faces)


;;;;;;;;;;;;;;;;;;;;;;;;;
;; REGULAR EXPRESSIONS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(setq real-earl-id-regexp
      "[A-Za-z_$]\\([A-Za-z_$]\\|-[A-Za-z_]\\)*")

(setq real-earl-wordop-regexp
      (concat
       "\\b"
       (regexp-opt '("with" "where" "each" "when" "in"
                     "and" "or" "as" "not" "mod" "of" "is"))
       "\\b"))

(setq real-earl-opchar-regexp
      "[-+*/~^<>=%&|?!@#.:]")

(setq real-earl-op-regexp
      (concat
       "\\(?:" real-earl-wordop-regexp "\\|" real-earl-opchar-regexp "\\)"
       real-earl-opchar-regexp "*"))

(setq real-earl-lowp-regexp
      (concat
       "^"
       (regexp-opt '(":" "->" "=>" "=" "+=" "-=" "/=" "*=" ">>=" "<<="
                     "with" "where" "each" "each="))
       "$"))

(setq real-earl-keymac-regexp
      "\\b\\(?:return\\|break\\|continue\\|pass\\|else\\|match\\|macro\\)\\b")
(setq real-earl-const-regexp
      "\\b\\(?:true\\|false\\|null\\|undefined\\)\\b")

(setq earl-id-regexp
      (regexp-opt earl-id-characters))
(setq earl-c1op-regexp
      (regexp-opt earl-c1op-characters))
(setq earl-c2op-regexp
      (concat (regexp-opt earl-c2op-characters) "+"))
(setq earl-list-sep-regexp
      (regexp-opt earl-list-sep-characters))
;; (setq earl-wordop-regexp
;;       "\\b\\(?:with\\|where\\|each\\|when\\|in\\|and\\|or\\|as\\|instanceof\\|not\\)\\b")
;; (setq earl-keymac-regexp
;;       "\\b\\(?:return\\|throw\\|delete\\|break\\|continue\\|match\\)\\b")

(setq earl-opchar-regexp
      (concat earl-c1op-regexp
              "\\|"
              earl-c2op-regexp
              "\\|"
              earl-list-sep-regexp))

(setq earl-word-regexp
      (concat earl-id-regexp "+"))

(setq earl-bracket-openers '(?\( ?\[ ?\{))
(setq earl-bracket-closers '(?\) ?\] ?\}))


;;;;;;;;;;;;;;;
;; UTILITIES ;;
;;;;;;;;;;;;;;;

(defun beginning-of-line-p (&optional pos)
  (save-excursion
    (if pos (goto-char pos))
    (skip-chars-backward " ")
    (bolp)))

(defun end-of-line-p (&optional pos)
  (save-excursion
    (if pos (goto-char pos))
    (skip-chars-forward " ")
    (or (eolp)
        (looking-at ";;"))))

;; (defun inside-encoding-p (&optional pos)
;;   (unless pos (setq pos (point)))
;;   (save-excursion
;;     (save-match-data
;;       (goto-char pos)
;;       (beginning-of-line)
;;       (catch 'return
;;         (while t
;;           (cond
;;            ((= (point) pos) (throw 'return nil))
;;            ((> (point) pos) (throw 'return t))
;;            (t (forward-char 1))))))))

;; (defun earl-re-search-forward (regexp &optional limit noerror repeat)
;;   (let ((rval nil))
;;     (setq rval (re-search-forward regexp limit noerror repeat))
;;     (while (and rval (inside-encoding-p))
;;       (goto-char (+ (match-beginning 0) 1))
;;       (setq rval (re-search-forward regexp limit noerror repeat)))
;;     rval))

;; (defun earl-re-search-backward (regexp &optional limit noerror repeat)
;;   (let ((rval nil))
;;     (setq rval (re-search-backward regexp limit noerror repeat))
;;     (while (and rval (inside-encoding-p))
;;       (goto-char (- (match-end 0) 1))
;;       (setq rval (re-search-backward regexp limit noerror repeat)))
;;     rval))

;; (defun earl-next-operator (&optional pos)
;;   (unless pos (setq pos (point)))
;;   (save-excursion
;;     (let ((line-span 1))
;;       (goto-char pos)
;;       (catch 'return
;;         (while t
;;           (let ((value (earl-forward-sexp-helper)))
;;             (cond
;;              ((equal value 'cont)
;;               (setq line-span (1+ line-span)))
;;              ((equal value 'comment)
;;               t)
;;              ((equal value 'operator)
;;               (throw 'return (and (<= (count-lines pos (point)) line-span)
;;                                   earl-last-token)))
;;              (t (throw 'return nil)))))))))

;; (defun earl-prev-operator (&optional pos)
;;   (unless pos (setq pos (point)))
;;   (save-excursion
;;     (goto-char pos)
;;     (let ((line-span (if (bolp) 0 1)))
;;       (catch 'return
;;         (while t
;;           (let ((value (earl-backward-sexp-helper)))
;;             (cond
;;              ((equal value 'cont)
;;               (setq line-span (1+ line-span)))
;;              ((equal value 'comment)
;;               t)
;;              ((equal value 'operator)
;;               (throw 'return (and (<= (count-lines pos (point)) line-span)
;;                                   earl-last-token)))
;;              (t (throw 'return nil)))))))))

;; (defun earl-looking-at-suffix ()
;;   (save-excursion
;;     (save-match-data
;;       (and (not (string-match "^\\(,\\|;\\|:\\)+$" earl-last-token))
;;            (or (string-match "^#+$" earl-last-token)
;;                (and (not (memq (char-before) '(?\  ?\n)))
;;                     (progn (earl-forward-operator-strict)
;;                            (or (memq (char-after) '(?\  ?\n))
;;                                (looking-at "\\\\")))))))))


;;;;;;;;;;;;
;; MOTION ;;
;;;;;;;;;;;;

;; (setq earl-last-token nil)

;; (defun earl-last-token-range (start end)
;;   (setq earl-last-token
;;         (buffer-substring-no-properties start end)))

;; (defun earl-forward-word-strict (&optional skip-chars skip-underscore)
;;   (skip-chars-forward (or skip-chars "_ \n"))
;;   (let ((success nil)
;;         (orig (point)))
;;     (while (and (looking-at earl-id-regexp)
;;                 (or skip-underscore
;;                     (not (equal (match-string 0) "_"))))
;;       (setq success t)
;;       (forward-char 1))
;;     (and success
;;          (earl-last-token-range orig (point)))))

;; (defun earl-backward-word-strict (&optional skip-chars skip-underscore)
;;   (skip-chars-backward (or skip-chars "_ \n"))
;;   (let ((success nil)
;;         (orig (point)))
;;     (condition-case nil
;;         (progn
;;           (backward-char 1)
;;           (while (and (looking-at earl-id-regexp)
;;                       (or skip-underscore
;;                           (not (equal (match-string 0) "_"))))
;;             (setq success t)
;;             (backward-char 1))
;;           (forward-char 1)
;;           success)
;;       (error success))
;;     (and success
;;          (earl-last-token-range (point) orig))))


;; (defun earl-forward-operator-strict (&optional skip-chars)
;;   (skip-chars-forward (or skip-chars " \n"))
;;   (let ((success nil)
;;         (orig (point)))
;;     (while (and (looking-at earl-opchar-regexp)
;;                 (not (save-match-data (looking-at "<<")))
;;                 (not (save-match-data (looking-at ">>"))))
;;       (setq success t)
;;       (forward-char 1))
;;     (and success
;;          (earl-last-token-range (point) orig))))

;; (defun earl-backward-operator-strict (&optional skip-chars)
;;   (skip-chars-backward (or skip-chars " \n"))
;;   (let ((success nil)
;;         (orig (point)))
;;     (condition-case nil
;;         (progn
;;           (backward-char 1)
;;           (while (and (looking-at earl-opchar-regexp)
;;                       (not (save-match-data (looking-at "<<")))
;;                       (not (save-match-data (looking-at ">>"))))
;;             (setq success t)
;;             (backward-char 1))
;;           (forward-char 1)
;;           success)
;;       (error success))
;;     (and success
;;          (earl-last-token-range (point) orig))))


;; (defun earl-forward-string-strict (&optional skip-chars)
;;   (skip-chars-forward (or skip-chars " \n"))
;;   (let ((orig (point)))
;;     (when
;;         (cond
;;          ((eq (char-after) ?\')
;;           (forward-char)
;;           (if (save-match-data (looking-at "`esc`"))
;;               (forward-char 1))
;;           (forward-char 1)
;;           t)
;;          ((eq (char-after) ?\")
;;           (forward-sexp)
;;           t)
;;          (t
;;           nil))
;;       (earl-last-token-range orig (point)))))

;; (defun earl-backward-string-strict (&optional skip-chars)
;;   (skip-chars-backward (or skip-chars " \n"))
;;   (let ((orig (point)))
;;     (backward-char 1)
;;     (when
;;         (cond
;;          ((or (looking-back "'")
;;               (looking-back "'`esc`"))
;;           (goto-char (match-beginning 0))
;;           t)
;;          ((eq (char-after) ?\")
;;           (forward-char)
;;           (backward-sexp)
;;           t)
;;          (t
;;           (forward-char 1)
;;           nil))
;;       (earl-last-token-range orig (point)))))
    


;; (defun earl-forward-list-strict (&optional skip-chars)
;;   (skip-chars-forward (or skip-chars " \n"))
;;   (let ((orig (point)))
;;     (if (not (memq (char-after) earl-bracket-openers))
;;         nil
;;       (forward-list)
;;       (earl-last-token-range orig (point)))))

;; (defun earl-backward-list-strict (&optional skip-chars)
;;   (skip-chars-backward (or skip-chars " \n"))
;;   (let ((orig (point)))
;;     (if (not (memq (char-before) earl-bracket-closers))
;;         nil
;;       (backward-list)
;;       (earl-last-token-range orig (point)))))


;; (defun earl-forward-comment-strict (&optional skip-chars)
;;   (skip-chars-forward (or skip-chars " \n"))
;;   (let* ((state (syntax-ppss))
;;          (in-comment (nth 4 state))
;;          (comment-start (nth 8 state)))
;;     (when in-comment
;;       (goto-char comment-start))
;;     (if (not (looking-at ";;\\|;("))
;;         nil
;;       (forward-comment (point))
;;       t)))

;; (defun earl-backward-comment-strict (&optional skip-chars)
;;   (skip-chars-backward (or skip-chars " \n"))
;;   (backward-char 1)
;;   (let* ((state (syntax-ppss))
;;          (in-comment (nth 4 state))
;;          (comment-start (nth 8 state)))
;;     (if in-comment
;;         (progn
;;           (goto-char comment-start)
;;           t)
;;       (forward-char 1)
;;       nil)))


;; (defun earl-forward-sexp-helper (&optional skip-chars)
;;   (unless skip-chars (setq skip-chars " \n"))
;;   (let ((x nil)
;;         (orig (point)))
;;     (let ((rval (or
;;                  (progn (setq x 'nil)
;;                         (skip-chars-forward skip-chars)
;;                         (setq orig (point))
;;                         (and (eobp)
;;                              (setq earl-last-token "")))
;;                  (progn (setq x 'comment)  (earl-forward-comment-strict skip-chars))
;;                  (progn (setq x 'string)   (earl-forward-string-strict skip-chars))
;;                  (progn (setq x 'word)     (earl-forward-word-strict skip-chars t))
;;                  (progn (setq x 'operator) (earl-forward-operator-strict skip-chars))
;;                  (progn (setq x 'list)     (earl-forward-list-strict skip-chars))
;;                  (progn (setq x 'cont)     (when (looking-at "\\\\")
;;                                              (forward-char 1)
;;                                              (earl-last-token-range orig (point))))
;;                  (progn (setq x 'nil)      (when (memq (char-after) earl-bracket-closers)
;;                                              (earl-last-token-range (point) (+ (point) 1))))
;;                  (progn (setq x 'other)    (forward-char 1)
;;                         (earl-last-token-range orig (point))))))
;;       x)))

;; (defun earl-backward-sexp-helper (&optional skip-chars)
;;   (unless skip-chars (setq skip-chars " \n"))
;;   (let ((x nil)
;;         (orig (point)))
;;     (let ((rval (or
;;                  (progn (setq x 'nil)
;;                         (skip-chars-backward skip-chars)
;;                         (setq orig (point))
;;                         (and (bobp)
;;                              (setq earl-last-token "")))
;;                  (progn (setq x 'comment)  (earl-backward-comment-strict skip-chars))
;;                  (progn (setq x 'string)   (earl-backward-string-strict skip-chars))
;;                  (progn (setq x 'word)     (earl-backward-word-strict skip-chars t))
;;                  (progn (setq x 'operator) (earl-backward-operator-strict skip-chars))
;;                  (progn (setq x 'list)     (earl-backward-list-strict skip-chars))
;;                  (progn (setq x 'cont)     (when (looking-back "\\\\")
;;                                              (backward-char 1)
;;                                              (earl-last-token-range orig (point))))
;;                  (progn (setq x 'nil)      (when (memq (char-before) earl-bracket-openers)
;;                                              (earl-last-token-range (- (point) 1) (point))))
;;                  (progn (setq x 'other)    (backward-char 1)
;;                         (earl-last-token-range orig (point))))))
;;       x)))


;; (defun earl-forward-word (&optional count)
;;   (interactive "p")
;;   (dotimes (i count)
;;     (let ((skip " \n<>\"'()[]{}"))
;;       (while (not (earl-forward-word-strict skip))
;;         (unless (earl-forward-operator-strict skip)
;;           (forward-char 1))))))

;; (defun earl-backward-word (&optional count)
;;   (interactive "p")
;;   (dotimes (i count)
;;     (let ((skip " \n<>\"'()[]{}"))
;;       (while (not (earl-backward-word-strict skip))
;;         (unless (earl-backward-operator-strict skip)
;;           (backward-char 1))))))

;; (defun earl-forward-sexp (&optional count)
;;   (interactive "p")
;;   (dotimes (i count)
;;     (earl-forward-sexp-helper)))

;; (defun earl-backward-sexp (&optional count)
;;   (interactive "p")
;;   (dotimes (i count)
;;     (earl-backward-sexp-helper)))


;;;;;;;;;;;;;;
;; DELETION ;;
;;;;;;;;;;;;;;

;; (defun earl-kill-word (&optional count)
;;   (interactive "p")
;;   (let ((orig (point)))
;;     (earl-forward-wor dcount)
;;     (kill-region orig (point))))

;; (defun earl-kill-backward-word (&optional count)
;;   (interactive "p")
;;   (let ((orig (point)))
;;     (earl-backward-word count)
;;     (kill-region orig (point))))


;; (defun earl-delete-char (&optional count)
;;   (interactive "p")
;;   (let ((orig (point)))
;;     (forward-char count)
;;     (delete-region orig (point))))

;; (defun earl-delete-backward-char (&optional count)
;;   (interactive "p")
;;   (let ((orig (point)))
;;     (cond
;;      ((beginning-of-line-p)
;;       (delete-backward-char 1)
;;       (while (and (equal (char-before) ?\ )
;;                   (not (zerop (mod (current-column) earl-indent))))
;;         (delete-backward-char 1)))
;;      (t
;;       (backward-char count)
;;       (delete-region (point) orig)))))


;;;;;;;;;;;;
;; INDENT ;;
;;;;;;;;;;;;

(defun earl-backspace ()
  (interactive)
  ;;(if (looking-back "^ +\\(?:| +\\)?")
  (if (looking-back "^ +")
      (earl-indent-back)
    (backward-delete-char 1)))

(defun earl-back-sexp ()
  (condition-case nil
      (let ((here (point))
            (target (scan-sexps (point) -1)))
        (if (= here target)
            nil
          (goto-char target)
          t))
    (error nil)))

(defun earl-indent-back ()
  (interactive)
  (let ((curr (current-column))
        (done nil)
        (new 0)
        (bar? nil))
    (defun backline ()
      (beginning-of-line)
      (condition-case nil (backward-char)
        (error (setq done t))))
    (save-excursion
      (while (not done)
        (cond
         ((or (= curr 0) (= (point) 0))
          (setq done t))
         ((and (looking-back "^ *")
               (looking-at " *$")
               (not (= (point) 0)))
          (backline))
         ((looking-back "^ *")
          (backline)
          (let ((indent (length (match-string 0))))
            (when (< indent curr)
              (setq done t)
              (setq new indent))))
         ((looking-back " +| ")
          (backward-char 2)
          (let ((indent (current-column)))
            (when (< indent curr)
              (setq done t)
              (setq bar? t)
              (setq new indent))))
         ;; ((backward-sexp)
         ;;  nil)
         ((earl-back-sexp)
          nil)
         ;; ((not (equal (earl-backward-sexp-helper) 'nil))
         ;;  nil)
         (t
          (setq done t)
          (let ((indent (car (earl-logical-indent))))
            (when (< indent curr)
              (setq new indent)))))))
    (earl-reindent new bar?)))


(defun earl-logical-indent (&optional pos)
  "Yields the indent of this particular line."
  (save-excursion
    (let ((done nil)
          (result 0)
          (bar? nil))
      (while (not done)
        (cond
         ((and (looking-at " *$")
               (looking-back "^ *")
               (not (= (point) 0)))
          (beginning-of-line)
          (backward-char))
         ((looking-back "^ *")
          (setq done t)
          (setq result (+ result (length (match-string 0)))))
         ((looking-back " +| ")
          (setq done t)
          (setq bar? t)
          (setq result (- (+ result (current-column)) 2)))
         ;; ((not (equal (earl-backward-sexp-helper) 'nil))
         ;;  nil)
         ((earl-back-sexp)
          nil)
         (t
          (if (and (looking-at " *$") (looking-back ".") (= result 0))
              (progn
                (setq result earl-indent)
                (backward-char))
            (setq done t)
            (setq result (+ result (current-column)))))))
      (cons result bar?))))

(defun earl-current-indent (&optional pos)
  "Yields the indent of this particular line."
  (save-excursion
    (if pos (goto-char pos))
    (beginning-of-line)
    (let ((n 0))
      (while (eq (char-after) ?\ )
        (setq n (+ n 1))
        (forward-char))
      n)))

(defun earl-count-lines (start end)
  (if (= start end)
      1
    (count-lines start end)))

(defun earl-reindent (new-indent bar?)
  (let ((orig (point))
        (current-indent (earl-current-indent)))
    (if (/= new-indent current-indent)
        (save-excursion
          (beginning-of-line)
          (delete-char current-indent)
          (dotimes (i new-indent)
            (insert-before-markers " "))
          (when bar?
            (insert-before-markers "| ")))
      (beginning-of-line)
      (forward-char new-indent)
      (if (> orig (point)) (goto-char orig)))))

(defun earl-indent-line ()
  (interactive)
  (earl-do-indent-line))

(defun earl-do-indent-line ()
  (let ((orig (point))
        (current-indent (earl-current-indent))
        (new-indent nil)
        (bar? nil))
    (save-excursion
      (beginning-of-line)
      (if (looking-at " *[]})]")
          (end-of-line)
        (previous-line)
        (end-of-line))
      (let* ((_curr (earl-logical-indent))
             (curr (car _curr)))
        (setq bar? (cdr _curr))
        ;; (if (or (earl-backward-operator-strict)
        ;;         (looking-back earl-wordop-regexp))
        (if (looking-back real-earl-op-regexp)
            (progn
              (setq bar? nil)
              (setq new-indent (+ curr earl-indent)))
          (setq new-indent curr))))
    (earl-reindent new-indent bar?)
    (cons new-indent bar?)))

(defun earl-indent-region (start end)
  (interactive)
  (save-excursion
    (goto-char start)
    (let* ((current-indent (earl-current-indent))
           (temp (earl-do-indent-line))
           (new-indent (car temp))
           (bar? (cdr temp))
           (delta (- new-indent current-indent))
           (the-end (+ end delta)))
      (next-line)
      (beginning-of-line)
      (while (< (point) the-end)
        (let ((curr (earl-current-indent)))
          (cond
           ((looking-at "^ *$")
            nil)
           ((< (+ curr delta) 0)
            (setq the-end -1))
           (t
            (earl-reindent (+ curr delta) bar?)
            (setq the-end (+ the-end delta)))))
        (next-line)
        (beginning-of-line)))))





(defvar earl-mode-map
  (let ((map (make-sparse-keymap)))

    (define-key map [backspace] 'earl-backspace)

    ;; (define-key map "\C-d" 'earl-delete-char)

    ;; (define-key map "\C-?" 'earl-delete-backward-char)
    ;; (define-key map "\C-d" 'earl-delete-char)
    (define-key map "\M-;" 'earl-comment-dwim)

    (define-key map "\C-c\C-j" 'earl-indent-back)
    (define-key map "\C-t" 'forward-char)
    (define-key map "\C-c\C-t" 'backward-char)
    ;; (define-key map [C-right] 'earl-forward-word)
    ;; (define-key map [C-left] 'earl-backward-word)
    ;; (define-key map "\C-\M-f" 'earl-forward-sexp)
    ;; (define-key map "\C-\M-b" 'earl-backward-sexp)
    ;; (define-key map [C-delete] 'earl-kill-word)
    ;; (define-key map [C-backspace] 'earl-kill-backward-word)
    map))


(defvar earl-mode-syntax-table
  (let ((table (make-syntax-table)))

    ;; Strings: ""
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?' "|" table)
    (modify-syntax-entry ?` "|" table)

    ;; Comments: ; ... \n or ;* ... *; or ;( ... );
    (modify-syntax-entry ?\; ". 124b" table)
    (modify-syntax-entry ?*  "_ 23n" table)
    (modify-syntax-entry ?\n "> b" table)

    ;; Brackets: () [] {}
    (modify-syntax-entry ?\( "() 2n" table)
    (modify-syntax-entry ?\) ")( 3n" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)

    ;; Symbols. Should be "_" but then x_2 highlights 2 as a number.
    (modify-syntax-entry ?_ "w" table)

    ;; Operator characters
    (modify-syntax-entry ?? "_" table)
    (modify-syntax-entry ?! "_" table)
    (modify-syntax-entry ?< "_" table)
    (modify-syntax-entry ?> "_" table)
    (modify-syntax-entry ?= "_" table)
    (modify-syntax-entry ?+ "_" table)
    (modify-syntax-entry ?- "_" table)
    (modify-syntax-entry ?* "_" table)
    (modify-syntax-entry ?/ "_" table)
    (modify-syntax-entry ?% "_" table)
    (modify-syntax-entry ?& "_" table)
    (modify-syntax-entry ?| "_" table)
    (modify-syntax-entry ?. "_" table)
    (modify-syntax-entry ?@ "_" table)
    (modify-syntax-entry ?~ "_" table)
    (modify-syntax-entry ?, "_" table)
    (modify-syntax-entry ?# "_" table)
    ;; (modify-syntax-entry ?' "_" table)

    table))




;;;;;;;;;;;;;;
;; Keywords ;;
;;;;;;;;;;;;;;

(defvar earl-mode-keywords
  `(;; Single character syntax
    ;; 'x is like "x". Note that this has to work for, say, '\lambda\
    ;; as well, so we use earl-codec-regexp to grab a full
    ;; character if possible. Note: '`esc`c is understood as 'c,
    ;; '`esc``br` as the unicode character ⏎ (whereas '`br` is \n).

    ;; Brackets
    ("[(){}]\\|\\[\\|\\]" . 'earl-font-lock-bracket)

    ;; Numbers
    ("\\(?:^\\|[^0-9rR]\\)\\(\\.[0-9][0-9_]*\\([eE]\\+?-?[0-9_]+\\)?\\)"
     1 'earl-font-lock-number) ;; start with dec pt .1, .999e99
    ("\\<[0-9][0-9_]*[rR][a-zA-Z0-9_]*\\(\\.[a-zA-Z0-9_]+\\)?\\>"
     . 'earl-font-lock-number) ;; radix notation 2r1001, 16rDEAD.BEEF
    ("\\<[0-9][0-9_]*\\(\\.[0-9_]+\\)?\\([eE]\\+?-?[0-9_]+\\)?\\>"
     . 'earl-font-lock-number) ;; decimal notation 104, 342.1, 10e-10

    ;; ;; Declaration
    ;; ;; Color var in: var <- value, var# <- value or var :: type
    ;; ;; var is only colored if the character just before is one of [({,;
    ;; ;; modulo whitespace. This is nice, as it highlights only b in
    ;; ;; a, b <- value, which will look odd to the user if he or she meant
    ;; ;; [a, b] <- value.
    ;; (,(concat "\\(?:^\\|[\\|[({,;]\\) *\\(\\(?:"
    ;;           earl-id-regexp
    ;;           "\\)*\\(?: *#\\)?\\) *\\(<-\\|::\\)")
    ;;  1 'earl-font-lock-assignment)

    ;; ;; Variable interpolation in strings: "\Up\(this) is interpolated"
    ;; ("$([^)]*)"
    ;;  0 'earl-font-lock-interpolation t)

    ;; Symbol: .blabla
    (,(concat "\\.\\(" real-earl-id-regexp "\\)+")
     . 'earl-font-lock-symbol)

    ;; Struct: #blabla
    (,(concat "[#]\\(" earl-id-regexp "\\)+")
     . 'earl-font-lock-prefix)

    ;; Prefixes: @blabla
    (,(concat "[@]\\(" real-earl-id-regexp "\\)*")
     . 'earl-font-lock-prefix)

    ;; ;; Operators
    ;; (,real-earl-op-regexp
    ;;  (0
    ;;   (cond
    ;;    ((member (match-string 0) '(":" "|"))
    ;;     'earl-font-lock-wordop)
    ;;    ((string-match real-earl-wordop-regexp (match-string 0))
    ;;     'earl-font-lock-wordop)
    ;;    (t
    ;;     'earl-font-lock-op))))

    ;; Operators
    (,real-earl-wordop-regexp
     (0
      (let ((x0 (match-beginning 0))
            (x1 (match-end 0)))
        (save-excursion
          (goto-char x1)
          (cond
           ((looking-at "-")
            nil)
           (t
            (goto-char x0)
            (cond
             ((looking-back "-")
              nil)
             (t
              'earl-font-lock-wordop))))))))

    ;; ;; Some macros that have no arguments and therefore won't be highlighted
    ;; (,real-earl-keymac-regexp
    ;;  . 'earl-font-lock-major-constructor)

    (,real-earl-const-regexp
     . 'earl-font-lock-special-constant)

    ;; Heuristic to highlight keywords
    (,real-earl-id-regexp
     (0
      (let ((x0 (match-beginning 0))
            (x1 (match-end 0)))
        (save-excursion
          (goto-char x1)
          (cond
           ((string-match real-earl-keymac-regexp (match-string 0))
            'earl-font-lock-major-constructor)
           ((looking-at " *:")
            (goto-char x0)
            (cond
             ((and (looking-back (concat " +\\(" real-earl-op-regexp "\\) +"))
                   (string-match real-earl-lowp-regexp (match-string 1)))
              'earl-font-lock-major-constructor)
             ((looking-back (concat "\\(^\\||\\) *"))
              'earl-font-lock-major-constructor)
             (t
              nil)))

           ((or (looking-at (concat " +" (regexp-opt '("(" "[" "{" "\""))))
                (looking-at (concat " +" real-earl-op-regexp real-earl-id-regexp))
                (looking-at " not ")
                (and
                 (looking-at (concat " +" real-earl-id-regexp))
                 (not (looking-at (concat " +" real-earl-op-regexp)))))
            (goto-char x0)
            (cond
             ((and (looking-back (concat " +\\(" real-earl-op-regexp "\\) +"))
                   (string-match real-earl-lowp-regexp (match-string 1)))
              'earl-font-lock-major-constructor)
             ((and (looking-back (concat real-earl-op-regexp " *"))
                   (not (looking-back " | *")))
             ;; ((looking-back (concat real-earl-op-regexp " *"))
              nil)
             (t
              'earl-font-lock-major-constructor)))
           (t
            'earl-font-lock-variable))))))

    ;; Operators
    (,real-earl-op-regexp
     (0
      (cond
       ((member (match-string 0) '(":" "|"))
        'earl-font-lock-wordop)
       ;; ((string-match real-earl-wordop-regexp (match-string 0))
       ;;  'earl-font-lock-wordop)
       (t
        'earl-font-lock-op))))

    )
  "Keywords for highlighting.")


(defvar earl-mode-syntactic-keywords
  `(

    ;; Capture operators as punctuation, before lumping them all
    ;; together as words with the rule just after that.
    (,(concat "\\(?:\\("
              earl-c2op-regexp
              "\\)\\)") 0
              (progn (if (equal (length (match-string 0)) 1)
                         nil
                       ".")))
    )
  "Syntactic keywords for earl.")


(define-derived-mode earl-mode fundamental-mode
  :syntax-table earl-mode-syntax-table
  ;(kill-all-local-variables)
  (setq font-lock-defaults
        '(earl-mode-keywords
          nil
          nil
          nil
          nil
          (font-lock-syntactic-keywords . earl-mode-syntactic-keywords)
          (indent-line-function . earl-indent-line)
          (indent-region-function . earl-indent-region)
          ))

  (setq major-mode 'earl-mode)
  (setq mode-name "Earl Grey"))

(defun earl-comment-dwim (&optional arg)
  "If no region is selected, inserts a comment at the
`comment-column'. If an uncommented region is selected, it is
commented: if the region falls in the middle of code, the region
is surrounded with ;(...);, else each line is prefixed
with ;;. If a commented region is selected, the region is
uncommented."
  ;; All this function does that comment-dwim doesn't is use the
  ;; nested ;(); comment format when commenting inside code (as
  ;; opposed to commenting whole lines, which prefixes them with
  ;; ;;). There is probably a better way to do this?

  ;; FIXME: (very minor) selecting any region starting with a comment
  ;; will fall back to the standard comment-dwim, even when we'd
  ;; rather use earl-comment-region (e.g. selecting ";(a); b" will
  ;; produce ";; ;(a); b" instead of the preferable ";( ;(a); b
  ;; );"). This is probably not worth fixing, unless there's an easy
  ;; way to tell comment-dwim to use earl-comment-region instead
  ;; of comment-region.
  (interactive "*P")
  (let ((comment-start ";; ")
        (comment-end ""))
    (if (and transient-mark-mode mark-active)
        (let ((orig (point))
              (beg (region-beginning))
              (end (region-end)))
          (save-excursion
            (goto-char beg)
            (if (not (looking-at "[ \n]*;\\(;\\|(\\)"))
                (earl-comment-region beg end)
              (goto-char orig)
              (comment-dwim arg))))
      (comment-dwim arg))))

(defun earl-comment-region (beg end)
  (interactive)
  (if
      (save-excursion
        (goto-char beg)
        (when (or (beginning-of-line-p)
                  (end-of-line-p))
          (goto-char end)
          (when (or (beginning-of-line-p)
                    (end-of-line-p))
            t)))
      (let ((comment-start ";; ")
            (comment-end ""))
        (comment-region beg end))
    (save-excursion
      (goto-char end)
      (skip-chars-backward " \n")
      (insert-before-markers " );")
      (goto-char beg)
      (skip-chars-forward " \n")
      (insert ";( "))))

(provide 'earl-mode)
