
;;; (load "earl-codec.el")
(load "earl-data.el")

;; We don't automatically turn on earl-use-codec in emacs version
;; 22 and earlier, and we don't bother with encoding Unicode
;; characters, should they be typed in (maybe that's fixable?
;; (char-to-string exotic-unicode-character) fails in emacs 22).
(setq earl-emacs-recent-enough (>= emacs-major-version 23))

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

(defface earl-font-lock-definition
  (earl-stock-face "dark green" "green")
  "Face for definitions, e.g. the color of 'f' in 'def f[x]: ...'"
  :group 'earl-faces)

;; Operator faces

(defface earl-font-lock-c3op
  (earl-stock-face "blue" "light blue")
  "Face for category 3 operators (+ - * / % etc.)"
  :group 'earl-faces)

(defface earl-font-lock-c4op
  (earl-stock-face "dark blue" "deep sky blue")
  "Face for category 4 operators (← :: ∧ ∨ etc.)"
  :group 'earl-faces)

;; Token faces

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

(setq earl-id-regexp
      (regexp-opt earl-id-characters))
(setq earl-c1op-regexp
      (regexp-opt earl-c1op-characters))
(setq earl-c2op-regexp
      (concat (regexp-opt earl-c2op-characters) "+"))
(setq earl-list-sep-regexp
      (regexp-opt earl-list-sep-characters))
(setq earl-wordop-regexp
      "\\b\\(?:with\\|where\\|each\\|when\\|in\\|and\\|or\\|as\\|instanceof\\|not\\)\\b")
(setq earl-keymac-regexp
      "\\b\\(?:return\\|throw\\|delete\\|break\\|continue\\|match\\)\\b")
;; (setq earl-c3op-regexp
;;       (regexp-opt earl-c3op-characters))
;; (setq earl-c4op-regexp
;;       (regexp-opt earl-c4op-characters))
(setq earl-opchar-regexp
      (concat earl-c1op-regexp
              "\\|"
              earl-c2op-regexp
              "\\|"
              earl-list-sep-regexp))
              ;; "\\|"
              ;; earl-c4op-regexp))

(setq earl-word-regexp
      (concat earl-id-regexp "+"))
;; (setq earl-c34op-regexp
;;       (concat "\\(?:\\("
;;               earl-c4op-regexp
;;               "\\)\\|\\("
;;               earl-c3op-regexp
;;               "\\)\\)+"))

;; (setq earl-escaped-char-literal-regexp
;;       (concat "'`esc`\\(" earl-codec-regexp "\\|.\\)"))
;; (setq earl-char-literal-regexp
;;       (concat "'\\(" earl-codec-regexp "\\|.\\)"))

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

(defun inside-encoding-p (&optional pos)
  (unless pos (setq pos (point)))
  (save-excursion
    (save-match-data
      (goto-char pos)
      (beginning-of-line)
      (catch 'return
        (while t
          (cond
           ((= (point) pos) (throw 'return nil))
           ((> (point) pos) (throw 'return t))
           (t (forward-char 1))))))))

(defun earl-re-search-forward (regexp &optional limit noerror repeat)
  (let ((rval nil))
    (setq rval (re-search-forward regexp limit noerror repeat))
    (while (and rval (inside-encoding-p))
      (goto-char (+ (match-beginning 0) 1))
      (setq rval (re-search-forward regexp limit noerror repeat)))
    rval))

(defun earl-re-search-backward (regexp &optional limit noerror repeat)
  (let ((rval nil))
    (setq rval (re-search-backward regexp limit noerror repeat))
    (while (and rval (inside-encoding-p))
      (goto-char (- (match-end 0) 1))
      (setq rval (re-search-backward regexp limit noerror repeat)))
    rval))

(defun earl-next-operator (&optional pos)
  (unless pos (setq pos (point)))
  (save-excursion
    (let ((line-span 1))
      (goto-char pos)
      (catch 'return
        (while t
          (let ((value (earl-forward-sexp-helper)))
            (cond
             ((equal value 'cont)
              (setq line-span (1+ line-span)))
             ((equal value 'comment)
              t)
             ((equal value 'operator)
              (throw 'return (and (<= (count-lines pos (point)) line-span)
                                  earl-last-token)))
             (t (throw 'return nil)))))))))

(defun earl-prev-operator (&optional pos)
  (unless pos (setq pos (point)))
  (save-excursion
    (goto-char pos)
    (let ((line-span (if (bolp) 0 1)))
      (catch 'return
        (while t
          (let ((value (earl-backward-sexp-helper)))
            (cond
             ((equal value 'cont)
              (setq line-span (1+ line-span)))
             ((equal value 'comment)
              t)
             ((equal value 'operator)
              (throw 'return (and (<= (count-lines pos (point)) line-span)
                                  earl-last-token)))
             (t (throw 'return nil)))))))))

(defun earl-looking-at-suffix ()
  (save-excursion
    (save-match-data
      (and (not (string-match "^\\(,\\|;\\|:\\)+$" earl-last-token))
           (or (string-match "^#+$" earl-last-token)
               (and (not (memq (char-before) '(?\  ?\n)))
                    (progn (earl-forward-operator-strict)
                           (or (memq (char-after) '(?\  ?\n))
                               (looking-at "\\\\")))))))))


;;;;;;;;;;;;
;; MOTION ;;
;;;;;;;;;;;;

;; (defun earl-forward-char (&optional count)
;;   (interactive "p")
;;   (let ((orig (point)))
;;     (dotimes (i count)
;;       ;; (save-match-data
;;       (if (looking-at earl-codec-regexp)
;;           (goto-char (match-end 0))
;;         (forward-char)))
;;     (- (point) orig)))

;; (defun earl-backward-char (&optional count)
;;   (interactive "p")
;;   (let ((orig (point)))
;;     (dotimes (i count)
;;       ;; (save-match-data
;;       (let ((orig (point)))
;;         (cond
;;          ((equal (char-before) ?`)
;;           (backward-char)
;;           (condition-case nil
;;               (save-match-data
;;                 (search-backward "`")
;;                 (if (looking-at earl-codec-named-code-regexp)
;;                     (goto-char (match-beginning 0))
;;                   (goto-char (- orig 1))))
;;             (error nil)))
;;          ((> (point) 2)
;;           (let ((consec 1))
;;             (save-excursion
;;               (backward-char 2)
;;               (condition-case nil
;;                   (while (looking-at earl-codec-digraph-regexp)
;;                     (setq consec (+ consec 1))
;;                     (backward-char))
;;                 (error nil)))
;;             (backward-char (- 2 (mod consec 2)))))
;;          (t
;;           (backward-char)))))
;;     (- orig (point))))

(setq earl-last-token nil)

(defun earl-last-token-range (start end)
  (setq earl-last-token
        (buffer-substring-no-properties start end)))

(defun earl-forward-word-strict (&optional skip-chars skip-underscore)
  (skip-chars-forward (or skip-chars "_ \n"))
  (let ((success nil)
        (orig (point)))
    (while (and (looking-at earl-id-regexp)
                (or skip-underscore
                    (not (equal (match-string 0) "_"))))
      (setq success t)
      (forward-char 1))
    (and success
         (earl-last-token-range orig (point)))))

(defun earl-backward-word-strict (&optional skip-chars skip-underscore)
  (skip-chars-backward (or skip-chars "_ \n"))
  (let ((success nil)
        (orig (point)))
    (condition-case nil
        (progn
          (backward-char 1)
          (while (and (looking-at earl-id-regexp)
                      (or skip-underscore
                          (not (equal (match-string 0) "_"))))
            (setq success t)
            (backward-char 1))
          (forward-char 1)
          success)
      (error success))
    (and success
         (earl-last-token-range (point) orig))))


(defun earl-forward-operator-strict (&optional skip-chars)
  (skip-chars-forward (or skip-chars " \n"))
  (let ((success nil)
        (orig (point)))
    (while (and (looking-at earl-opchar-regexp)
                (not (save-match-data (looking-at "<<")))
                (not (save-match-data (looking-at ">>"))))
      (setq success t)
      (forward-char 1))
    (and success
         (earl-last-token-range (point) orig))))

(defun earl-backward-operator-strict (&optional skip-chars)
  (skip-chars-backward (or skip-chars " \n"))
  (let ((success nil)
        (orig (point)))
    (condition-case nil
        (progn
          (backward-char 1)
          (while (and (looking-at earl-opchar-regexp)
                      (not (save-match-data (looking-at "<<")))
                      (not (save-match-data (looking-at ">>"))))
            (setq success t)
            (backward-char 1))
          (forward-char 1)
          success)
      (error success))
    (and success
         (earl-last-token-range (point) orig))))


(defun earl-forward-string-strict (&optional skip-chars)
  (skip-chars-forward (or skip-chars " \n"))
  (let ((orig (point)))
    (when
        (cond
         ((eq (char-after) ?\')
          (forward-char)
          (if (save-match-data (looking-at "`esc`"))
              (forward-char 1))
          (forward-char 1)
          t)
         ((eq (char-after) ?\")
          (forward-sexp)
          t)
         (t
          nil))
      (earl-last-token-range orig (point)))))

(defun earl-backward-string-strict (&optional skip-chars)
  (skip-chars-backward (or skip-chars " \n"))
  (let ((orig (point)))
    (backward-char 1)
    (when
        (cond
         ((or (looking-back "'")
              (looking-back "'`esc`"))
          (goto-char (match-beginning 0))
          t)
         ((eq (char-after) ?\")
          (forward-char)
          (backward-sexp)
          t)
         (t
          (forward-char 1)
          nil))
      (earl-last-token-range orig (point)))))
    


(defun earl-forward-list-strict (&optional skip-chars)
  (skip-chars-forward (or skip-chars " \n"))
  (let ((orig (point)))
    (if (not (memq (char-after) earl-bracket-openers))
        nil
      (forward-list)
      (earl-last-token-range orig (point)))))

(defun earl-backward-list-strict (&optional skip-chars)
  (skip-chars-backward (or skip-chars " \n"))
  (let ((orig (point)))
    (if (not (memq (char-before) earl-bracket-closers))
        nil
      (backward-list)
      (earl-last-token-range orig (point)))))


(defun earl-forward-comment-strict (&optional skip-chars)
  (skip-chars-forward (or skip-chars " \n"))
  (let* ((state (syntax-ppss))
         (in-comment (nth 4 state))
         (comment-start (nth 8 state)))
    (when in-comment
      (goto-char comment-start))
    (if (not (looking-at ";;\\|;("))
        nil
      (forward-comment (point))
      t)))

(defun earl-backward-comment-strict (&optional skip-chars)
  (skip-chars-backward (or skip-chars " \n"))
  (backward-char 1)
  (let* ((state (syntax-ppss))
         (in-comment (nth 4 state))
         (comment-start (nth 8 state)))
    (if in-comment
        (progn
          (goto-char comment-start)
          t)
      (forward-char 1)
      nil)))


(defun earl-forward-sexp-helper (&optional skip-chars)
  (unless skip-chars (setq skip-chars " \n"))
  (let ((x nil)
        (orig (point)))
    (let ((rval (or
                 (progn (setq x 'nil)
                        (skip-chars-forward skip-chars)
                        (setq orig (point))
                        (and (eobp)
                             (setq earl-last-token "")))
                 (progn (setq x 'comment)  (earl-forward-comment-strict skip-chars))
                 (progn (setq x 'string)   (earl-forward-string-strict skip-chars))
                 (progn (setq x 'word)     (earl-forward-word-strict skip-chars t))
                 (progn (setq x 'operator) (earl-forward-operator-strict skip-chars))
                 (progn (setq x 'list)     (earl-forward-list-strict skip-chars))
                 (progn (setq x 'cont)     (when (looking-at "\\\\")
                                             (forward-char 1)
                                             (earl-last-token-range orig (point))))
                 (progn (setq x 'nil)      (when (memq (char-after) earl-bracket-closers)
                                             (earl-last-token-range (point) (+ (point) 1))))
                 (progn (setq x 'other)    (forward-char 1)
                        (earl-last-token-range orig (point))))))
      x)))

(defun earl-backward-sexp-helper (&optional skip-chars)
  (unless skip-chars (setq skip-chars " \n"))
  (let ((x nil)
        (orig (point)))
    (let ((rval (or
                 (progn (setq x 'nil)
                        (skip-chars-backward skip-chars)
                        (setq orig (point))
                        (and (bobp)
                             (setq earl-last-token "")))
                 (progn (setq x 'comment)  (earl-backward-comment-strict skip-chars))
                 (progn (setq x 'string)   (earl-backward-string-strict skip-chars))
                 (progn (setq x 'word)     (earl-backward-word-strict skip-chars t))
                 (progn (setq x 'operator) (earl-backward-operator-strict skip-chars))
                 (progn (setq x 'list)     (earl-backward-list-strict skip-chars))
                 (progn (setq x 'cont)     (when (looking-back "\\\\")
                                             (backward-char 1)
                                             (earl-last-token-range orig (point))))
                 (progn (setq x 'nil)      (when (memq (char-before) earl-bracket-openers)
                                             (earl-last-token-range (- (point) 1) (point))))
                 (progn (setq x 'other)    (backward-char 1)
                        (earl-last-token-range orig (point))))))
      x)))


(defun earl-forward-word (&optional count)
  (interactive "p")
  (dotimes (i count)
    (let ((skip " \n<>\"'()[]{}"))
      (while (not (earl-forward-word-strict skip))
        (unless (earl-forward-operator-strict skip)
          (forward-char 1))))))

(defun earl-backward-word (&optional count)
  (interactive "p")
  (dotimes (i count)
    (let ((skip " \n<>\"'()[]{}"))
      (while (not (earl-backward-word-strict skip))
        (unless (earl-backward-operator-strict skip)
          (backward-char 1))))))

(defun earl-forward-sexp (&optional count)
  (interactive "p")
  (dotimes (i count)
    (earl-forward-sexp-helper)))

(defun earl-backward-sexp (&optional count)
  (interactive "p")
  (dotimes (i count)
    (earl-backward-sexp-helper)))


;;;;;;;;;;;;;;
;; DELETION ;;
;;;;;;;;;;;;;;

(defun earl-kill-word (&optional count)
  (interactive "p")
  (let ((orig (point)))
    (earl-forward-word count)
    (kill-region orig (point))))

(defun earl-kill-backward-word (&optional count)
  (interactive "p")
  (let ((orig (point)))
    (earl-backward-word count)
    (kill-region orig (point))))


(defun earl-delete-char (&optional count)
  (interactive "p")
  (let ((orig (point)))
    (forward-char count)
    (delete-region orig (point))))

(defun earl-delete-backward-char (&optional count)
  (interactive "p")
  (let ((orig (point)))
    (cond
     ((beginning-of-line-p)
      (delete-backward-char 1)
      (while (and (equal (char-before) ?\ )
                  (not (zerop (mod (current-column) earl-indent))))
        (delete-backward-char 1)))
     (t
      (backward-char count)
      (delete-region (point) orig)))))


;;;;;;;;;;;;;;;;;;;;;;
;; FIND CONSTRUCTOR ;;
;;;;;;;;;;;;;;;;;;;;;;

(defun earl-find-constructor (&optional pos nocont)
  (unless pos (setq pos (point)))
  (save-excursion
    (save-match-data
      (let ((line-span (if (bolp) 0 1))
            (end-of-constructor nil)
            (len 0)
            (rval pos))
        (goto-char pos)
        (catch 'return
          (while t
            (let* ((value (earl-backward-sexp-helper))
                   (last-token earl-last-token))
              (cond

               ;; There is a suffix operator like in "a b# c: d", and
               ;; in this case we remember where the suffix op is
               ;; located (we will highlight up to there) and we keep
               ;; going until we find some infix or prefix
               ;; operator. Note that we keep going conservatively,
               ;; i.e. "a + b* c: d" will only highlight "b*" even
               ;; though "*" might have lower priority than "+".
               ((and (equal value 'operator)
                     (earl-looking-at-suffix))
                (setq end-of-constructor (+ (point) (length last-token))))

               ;; There is an operator there. We stop.
               ((and (equal value 'operator)
                     (not (string-match "^\\(\\.\\|\\$\\|@\\)+$" last-token)))
                (throw 'return (cons rval (or end-of-constructor (+ rval len)))))

               ;; There is a line continuation. We extend the
               ;; line-span to tolerate going up to the line where the
               ;; continuation is located.
               ((and (equal value 'cont)
                     (not nocont))
                (setq line-span (count-lines pos (point))))

               ;; We ignore comments completely.
               ((equal value 'comment)
                t)

               ;; Parens/bracket start. We stop.
               ((equal value 'nil)
                (throw 'return (cons rval (or end-of-constructor (+ rval len)))))

               ;; A bit convoluted, but this is a () sexp that ends on
               ;; the same line we were, but may start on another
               ;; line. We extend line-span.
               ((and (member value '(list string))
                     (not (> (count-lines pos (+ (point) (length last-token))) line-span)))
                (setq line-span (count-lines pos (point)))
                (setq rval (point))
                (setq len (length last-token)))

               ;; We check if we're still on the same line, or a
               ;; previous line if the line-span was extended. If we
               ;; are too far, we stop.
               ((> (count-lines pos (point)) line-span)
                (throw 'return (cons rval (or end-of-constructor (+ rval len)))))

               ;; Anything else we skip over.
               (t
                (setq rval (point))
                (setq len (length last-token)))))))))))


;;;;;;;;;;;;
;; INDENT ;;
;;;;;;;;;;;;

(defun earl-backspace ()
  (interactive)
  ;;(if (looking-back "^ +\\(?:| +\\)?")
  (if (looking-back "^ +")
      (earl-indent-back)
    (backward-delete-char 1)))

(defun earl-indent-back ()
  (interactive)
  (let ((curr (current-column))
        (done nil)
        (new 0)
        (bar? nil))
    (save-excursion
      (while (not done)
        (cond
         ((or (= curr 0) (= (point) 0))
          (setq done t))
         ((and (looking-back "^ *")
               (looking-at " *$")
               (not (= (point) 0)))
          (beginning-of-line)
          (backward-char))          
         ((looking-back "^ *")
          (beginning-of-line)
          (backward-char)
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
         ((not (equal (earl-backward-sexp-helper) 'nil))
          nil)
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
         ((not (equal (earl-backward-sexp-helper) 'nil))
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
        (if (or (earl-backward-operator-strict)
                (looking-back earl-wordop-regexp))
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
            (earl-reindent (+ curr delta) bar?))))
        (setq the-end (+ the-end delta))
        (next-line)
        (beginning-of-line)))))





(defvar earl-mode-map
  (let ((map (make-sparse-keymap)))
    ;; (define-key map "\C-c\C-u" 'earl-codec-mode)

    (define-key map [backspace] 'earl-backspace)

    (define-key map "\C-d" 'earl-delete-char)

    (define-key map "\C-?" 'earl-delete-backward-char)
    (define-key map "\C-d" 'earl-delete-char)
    (define-key map "\M-;" 'earl-comment-dwim)
    ;; (define-key map "\C-c\C-e" 'earl-encode-region)
    (define-key map "\C-j" 'earl-newline)
    (define-key map [C-return] 'earl-newline)
    ;; (define-key map "(" 'earl-electric-opening-parens)
    ;; (define-key map "[" 'earl-electric-opening-bracket)
    ;; (define-key map "{" 'earl-electric-opening-brace)
    ;; (define-key map ")" 'earl-electric-closing-parens)
    ;; (define-key map "]" 'earl-electric-closing-bracket)
    ;; (define-key map "}" 'earl-electric-closing-brace)

    (define-key map "\C-c\C-j" 'earl-indent-back)
    (define-key map "\C-t" 'forward-char)
    (define-key map "\C-c\C-t" 'backward-char)
    (define-key map [C-right] 'earl-forward-word)
    (define-key map [C-left] 'earl-backward-word)
    (define-key map "\C-\M-f" 'earl-forward-sexp)
    (define-key map "\C-\M-b" 'earl-backward-sexp)
    (define-key map [C-delete] 'earl-kill-word)
    (define-key map [C-backspace] 'earl-kill-backward-word)
    map))

(defun earl-add-encoder (encoder)
  (let ((c (car encoder))
        (repl (cdr encoder)))
    (define-key earl-mode-map (char-to-string c) repl)))

;; (if earl-emacs-recent-enough
;;     (mapcar 'earl-add-encoder earl-codec-encode-list))


(defvar earl-encoder-table
  (make-hash-table :test 'eq)
  "Hash table mapping unicode character code -> string encoding.")

(defun earl-encoder-add-entry (entry)
  (let ((character (car entry))
        (encoding (cdr entry)))
    (puthash character encoding earl-encoder-table)))

;; (mapcar 'earl-encoder-add-entry earl-codec-encode-list)


(defvar earl-mode-syntax-table
  (let ((table (make-syntax-table)))

    ;; Strings: ""
    (modify-syntax-entry ?\" "\"" table)

    ;; Comments: ; ... \n or ;* ... *; or ;( ... );
    (modify-syntax-entry ?\; ". 124b" table)
    (modify-syntax-entry ?*  ". 23n" table)
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
    (modify-syntax-entry ?? "." table)
    (modify-syntax-entry ?! "." table)
    (modify-syntax-entry ?< "." table)
    (modify-syntax-entry ?> "." table)
    (modify-syntax-entry ?= "." table)
    (modify-syntax-entry ?+ "." table)
    (modify-syntax-entry ?- "." table)
    (modify-syntax-entry ?* "." table)
    (modify-syntax-entry ?/ "." table)
    (modify-syntax-entry ?% "." table)
    (modify-syntax-entry ?& "." table)
    (modify-syntax-entry ?| "." table)
    (modify-syntax-entry ?. "." table)
    (modify-syntax-entry ?@ "." table)
    (modify-syntax-entry ?~ "." table)
    (modify-syntax-entry ?, "." table)

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

    ;; Declaration
    ;; Color var in: var <- value, var# <- value or var :: type
    ;; var is only colored if the character just before is one of [({,;
    ;; modulo whitespace. This is nice, as it highlights only b in
    ;; a, b <- value, which will look odd to the user if he or she meant
    ;; [a, b] <- value.
    (,(concat "\\(?:^\\|[\\|[({,;]\\) *\\(\\(?:"
              earl-id-regexp
              "\\)*\\(?: *#\\)?\\) *\\(<-\\|::\\)")
     1 'earl-font-lock-assignment)

    ;; Variable interpolation in strings: "\Up\(this) is interpolated"
    ("$([^)]*)"
     0 'earl-font-lock-interpolation t)

    ;; Symbol: .blabla
    (,(concat "\\. *\\(" earl-id-regexp "\\)+")
     . 'earl-font-lock-symbol)

    ;; Struct: #blabla
    (,(concat "[#~] *\\(" earl-id-regexp "\\)+")
     . 'earl-font-lock-prefix)

    ;; Prefixes: @blabla or $blabla (or @   blabla)
    (,(concat "[@$] *\\(" earl-id-regexp "\\)*")
     . 'earl-font-lock-prefix)

    ;; Suffixes: blabla# (or blabla         #)
    (,(concat "\\(" earl-id-regexp "\\)* *#")
     . 'earl-font-lock-suffix)

    ;; ("\\b\\(?:with\\|where\\|when\\|in\\|and\\|or\\|as\\|instanceof)\\b"
    (,earl-wordop-regexp
     . 'earl-font-lock-major-constructor)

    (,earl-keymac-regexp
     . 'earl-font-lock-major-constructor)

    ;; Operators
    (,earl-c2op-regexp
     (0 (cond

         ;; First case is the ":" operator. In the expression "a b:
         ;; c", which means a(:){b, c} we want to highlight "a" (the
         ;; control structure)
         ((equal (match-string 0) ":")
          (let* (;; pos <- the start of the identifier to highlight
                 ;(pos (earl-backward-primary-sexp (match-beginning 0)))
                 (constructor-range (earl-find-constructor (match-beginning 0)))
                 (constructor-start (car constructor-range))
                 (constructor-end (cdr constructor-range))
                 (state (syntax-ppss))
                 ;; Are we in a string or a comment?
                 (inactive-region (or (nth 3 state) (nth 4 state))))
            (if inactive-region
                ;; If we are in a string or a comment, we don't want to
                ;; highlight something weird, or override the string
                ;; highlighting (we highlight the control structure with
                ;; put-text-property directly, so it overrides string
                ;; highlighting - maybe there's a better way to do it?)
                nil
              (save-excursion
                (goto-char constructor-start)
                (;when (looking-at earl-word-regexp)
                 let ((text (buffer-substring-no-properties constructor-start constructor-end)))
                  (cond
                   ;; A. The identifier starts a definition, i.e. "def"
                   ((member text earl-definition-constructors)
                    ;; We highlight "def" (or whatever definition constructor this is)
                    (put-text-property ;(match-beginning 0) (match-end 0)
                                       constructor-start constructor-end
                                       'face 'earl-font-lock-major-constructor)
                    (goto-char constructor-end) ; (match-end 0))
                    (skip-chars-forward " ") ;; we align ourselves on the next expression
                    (if (looking-at earl-word-regexp)
                        ;; We highlight the second term, e.g. in "def f[x]:"
                        ;; we highlight f.
                        (put-text-property ;constructor-start constructor-end
                                           (match-beginning 0) (match-end 0)
                                           'face 'earl-font-lock-definition)))
                   ;; B. The identifier is important, i.e. "if", "else", "for", "\lambda\"
                   ((member text earl-major-constructors)
                    (put-text-property constructor-start constructor-end
                                       ;(match-beginning 0) (match-end 0)
                                       'face 'earl-font-lock-major-constructor))
                   ;; C. The identifier is unknown, but we still
                   ;; highlight it, albeit differently than if it was
                   ;; known (default is bold black, which is less
                   ;; visible).
                   (t
                    (put-text-property constructor-start constructor-end
                                       ;(match-beginning 0) (match-end 0)
                                       'face 'earl-font-lock-constructor)))))
              ;; The highlighted term might not be on the same line as
              ;; the ":", so it's important to set the
              ;; font-lock-multiline property on the whole range.
              (put-text-property constructor-start (point) 'font-lock-multiline t)
              ;; (if (end-of-line-p (point))
              ;;     'earl-font-lock-warning
              'earl-font-lock-constructor)))

         ;; ((match-string 1)
         ;;  ;; Second case are category 4 operators. Characters in
         ;;  ;; categories 3 and 4 can be mixed together, but if there is
         ;;  ;; at least one c4 character, the whole op is promoted to c4
         ;;  ;; and we use the c4 face.
         ;;  'earl-font-lock-c4op)

         (t
          ;; Third case, there are only c3 characters, so it's a c3 op.
          'earl-font-lock-c3op))))

    ("." 0 (let ((c (char-before)))
             (if (or (= c ?\t)
                     (> (char-before) 127))
                 'earl-font-lock-invalid
               nil)))
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

  ;; (if earl-use-codec
  ;;     (earl-codec-mode t))

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

;; (defun earl-encode-range (beg end)
;;   (when (> beg end)
;;     (let ((tmp beg))
;;       (setq beg end)
;;       (setq end tmp)))
;;   (save-excursion
;;     (goto-char beg)
;;     (if (inside-encoding-p)
;;         (error "The region to encode does not start at an encoding boundary."))
;;     (let ((m (make-marker))
;;           (inside-encoding nil))
;;       (set-marker m end)
;;       (while (or (< (point) m)
;;                  inside-encoding)
;;         (let ((c (char-after)))
;;           (cond
;;            ;; Unicode characters must be encoded.
;;            ((> c 127)
;;             (delete-char 1)
;;             (insert-before-markers (gethash c earl-encoder-table)))
;;            ;; All slashes are assumed to be literal, so they are doubled
;;            ((= c ?`)
;;             (setq inside-encoding (not inside-encoding))
;;             (delete-char 1)
;;             (insert-before-markers "``"))
;;            ;; Digraphs are escaped, e.g. <- becomes `<``-`
;;            ((looking-at earl-codec-digraph-regexp)
;;             (delete-char 1)
;;             (insert-before-markers "`" (char-to-string c) "`")
;;             (setq c (char-after))
;;             (delete-char 1)
;;             (insert-before-markers "`" (char-to-string c) "`"))
;;            ;; Other characters are ignored
;;            (t
;;             (forward-char))))))
;;     (point)))

;; (defun earl-encode-region (&optional count)
;;   "Encode the region using the Earl Grey encoding. Unicode
;; characters are encoded, e.g. λ as `lambda` and ← as
;; <-. Expressions that normally encode characters are encoded as
;; well, e.g. `lambda` will become ``lambda`` and <- will
;; become `<``-`. If this command is executed right after a
;; yank (paste), the whole pasted region will be encoded."
;;   (interactive "p")
;;   (if (and transient-mark-mode mark-active)      
;;       (goto-char (earl-encode-range (region-beginning) (region-end)))
;;     (if (eq last-command 'yank)
;;         (goto-char (earl-encode-range (point) (mark)))
;;       (goto-char (earl-encode-range (point) (+ (point) count))))))

(defun earl-newline ()
  "Inserts a new line and indents it. If the point is right after
  the \":\" operator, this inserts \"(\", then a newline, then
  \")\" on the line right after that, and then places the point
  on the new line between the brackets. If anything was after the
  colon, it will be placed on its own line and the point will be
  placed after it."
  (interactive)
  (cond
   ((or (bobp) (eobp))
    (insert "\n"))
   (t
    (while (= (char-before) ?\ )
      (delete-backward-char 1))
    (while (= (char-after) ?\ )
      (delete-char 1))
    (if (not (equal (earl-prev-operator) ":"))
        (insert "\n")
      (insert " (\n")
      (earl-indent-line)
      (if (end-of-line-p)
          (insert "\n)")
        (end-of-line)
        (insert "\n\n)"))
      (earl-indent-line)
      (beginning-of-line)
      (backward-char))
    (earl-indent-line))))

(defun earl-electric-closing-delimiter (delim)
  ;; (if (and (looking-at (concat "[ \n]*" delim))
  ;;          (= (earl-compute-indent (match-end 0))
  ;;             (earl-current-indent (match-end 0))))
  ;;     (goto-char (match-end 0))
    (insert delim)
    (earl-indent-line))

(defun earl-electric-closing-parens ()
  (interactive)
  (earl-electric-closing-delimiter ")"))

(defun earl-electric-closing-bracket ()
  (interactive)
  (earl-electric-closing-delimiter "]"))

(defun earl-electric-closing-brace ()
  (interactive)
  (earl-electric-closing-delimiter "}"))



(defun earl-electric-opening-delimiter (open close)
  (insert open))
  ;; (insert close)
  ;; (backward-char))

(defun earl-electric-opening-parens ()
  (interactive)
  (earl-electric-opening-delimiter "(" ")"))

(defun earl-electric-opening-bracket ()
  (interactive)
  (earl-electric-opening-delimiter "["  "]"))

(defun earl-electric-opening-brace ()
  (interactive)
  (earl-electric-opening-delimiter "{"  "}"))


(provide 'earl-mode)


;; What to do
;; x Replace \in\ by ∈, etc.
;;   x Make it so that inputting ∈ produces \in\ internally, etc.
;;   x Option to always show expanded version
;;   x Option to never show expanded version
;;   - Option to show the expanded version for the current line
;; x Different colors for:
;;   x Identifier characters
;;   x Strict operator characters
;;   x Lazy operator characters
;;   x Illegal characters
;; x Comments
;;   x ;; ... \n
;;   x ;* ... *;
;; x Strings
;;   x ""
;;   x «» (nested)
;;   x Variable interpolation: ⇑()
;; x Bold face or different color for X in X: Y
;; x Indent rules
;; x Electric parens?

;; FIXME: (very minor) a (b \nc):+ ... does not highlight "a", which
;; is the proper behavior since ":+" is not a special operator, but
;; when the + is removed, "a" is not automatically highlighted. It is
;; highlighted eventually, or if one deletes and reinserts ":". Not
;; sure if there is an easy fix (nor if this ever even occurs in real
;; situations). Extending the range of the font-lock-multiline
;; property did not seem to fix. Same kind of problem happens before
;; the structure, e.g. removing "+" in "a [b\nc] + d:"

;; FIXED with font-lock-multiline? FIXME: there is an issue when
;; editing a multiline <<>> string, which seems to prevent the
;; highlighting of other <<>> strings after it. Re-fontifying the
;; buffer works, and so does modifying lines that are after, or close
;; to the end of the construct.

;; FIXME: (minor) \esc\<< and \esc\>> should not open or close quotes,
;; i.e. <<a b c \esc\>> d e>> is a well-formed complete quote. \esc\<<
;; is escaped properly, it's the closing form that's not handled.
