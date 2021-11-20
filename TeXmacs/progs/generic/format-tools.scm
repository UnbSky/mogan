
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : format-tools.scm
;; DESCRIPTION : Widgets for text, paragraph and page properties
;; COPYRIGHT   : (C) 2013-2021  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; See menu-define.scm for the grammar of menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (generic format-tools)
  (:use (generic format-widgets)
        (utils library cursor)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (window-get-env win l mode)
  (with-window win
    (cond ((== mode :here)
           (get-env l))
          ((== mode :paragraph)
           (get-env l))
          ((== mode :global)
           (get-init l))
          (else ""))))

(tm-define (window-set-env win l val mode)
  (with-window win
    (cond ((== mode :here)
           (make-with (list l val)))
          ((== mode :paragraph)
           (make-multi-line-with (list l val)))
          ((== mode :global)
           (init-env l val)))))

(define tool-key-table (make-ahash-table))

(tm-define (tool-ref key)
  (ahash-ref tool-key-table key))

(tm-define (tool-set key val)
  (ahash-set! tool-key-table key val))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Paragraph properties
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-widget (paragraph-basic-tool win mode)
  (refreshable "paragraph tool"
    (aligned
      (item (text "Alignment:")
        (enum (window-set-env win "par-mode" answer mode)
              '("left" "center" "right" "justify")
              (window-get-env win "par-mode" mode) "10em"))
      (assuming (== mode :paragraph)
        (item ====== ======)
        (item (text "Left margin:")
          (enum (window-set-env win "par-left" answer mode)
                (cons-new (window-get-env win "par-left" mode)
                          '("0tab" "1tab" "2tab" ""))
                (window-get-env win "par-left" mode) "10em"))
        (item (text "Right margin:")
          (enum (window-set-env win "par-right" answer mode)
                (cons-new (window-get-env win "par-right" mode)
                          '("0tab" "1tab" "2tab" ""))
                (window-get-env win "par-right" mode) "10em")))
      (item (text "First indentation:")
        (enum (window-set-env win "par-first" answer mode)
              (cons-new (window-get-env win "par-first" mode)
                        '("0tab" "1tab" "-1tab" ""))
              (window-get-env win "par-first" mode) "10em"))
      (item ====== ======)
      (item (text "Interline space:")
        (enum (window-set-env win "par-sep" answer mode)
              (cons-new (window-get-env win "par-sep" mode)
                        '("0fn" "0.2fn" "0.5fn" "1fn" ""))
              (window-get-env win "par-sep" mode) "10em"))
      (item (text "Interparagraph space:")
        (enum (window-set-env win "par-par-sep" answer mode)
              (cons-new (window-get-env win "par-par-sep" mode)
                        '("0fn" "0.3333fn" "0.5fn" "0.6666fn"
                          "1fn" "0.5fns" ""))
              (window-get-env win "par-par-sep" mode) "10em"))
      (item ====== ======)
      (item (text "Number of columns:")
        (enum (begin
                (window-set-env win "par-columns" answer mode)
                (refresh-now "paragraph-tool-columns"))
              '("1" "2" "3" "4" "5" "6")
              (window-get-env win "par-columns" mode) "10em"))
      (item (when (!= (window-get-env win "par-columns" mode) "1")
              (text "Column separation:"))
        (refreshable "paragraph-formatter-columns-sep"
          (when (!= (window-get-env win "par-columns" mode) "1")
            (enum (window-set-env win "par-columns-sep" answer mode)
                  (cons-new (window-get-env win "par-columns-sep" mode)
                            '("1fn" "2fn" "3fn" ""))
                  (window-get-env win "par-columns-sep" mode) "10em"))))
      (assuming (tool-ref (list win mode "advanced paragraph"))
        (item ====== ======)
        (item === ===)
        (item (text "Line breaking:")
          (enum (window-set-env win "par-hyphen" answer mode)
                '("normal" "professional")
                (window-get-env win "par-hyphen" mode) "10em"))
        (item ====== ======)
        (item (text "Extra interline space:")
          (enum (window-set-env win "par-line-sep" answer mode)
                (cons-new (window-get-env win "par-line-sep" mode)
                          '("0fn" "0.025fns" "0.05fns" "0.1fns"
                            "0.2fns" "0.5fns" "1fns" ""))
                (window-get-env win "par-line-sep" mode) "10em"))
        (item (text "Minimal line separation:")
          (enum (window-set-env win "par-ver-sep" answer mode)
                (cons-new (window-get-env win "par-ver-sep" mode)
                          '("0fn" "0.1fn" "0.2fn" "0.5fn" "1fn" ""))
                (window-get-env win "par-ver-sep" mode) "10em"))
        (item (text "Horizontal collapse distance:")
          (enum (window-set-env win "par-hor-sep" answer mode)
                (cons-new (window-get-env win "par-hor-sep" mode)
                          '("0.1fn" "0.2fn" "0.5fn" "1fn"
                            "2fn" "5fn" "10fn" "100fn" ""))
                (window-get-env win "par-hor-sep" mode) "10em"))
        (item ====== ======)
        (item (text "Space stretchability:")
          (enum (window-set-env win "par-flexibility" answer mode)
                (cons-new (window-get-env win "par-flexibility" mode)
                          '("1" "2" "4" "1000" ""))
                (window-get-env win "par-flexibility" mode) "10em"))
        (item (text "CJK spacing:")
          (enum (window-set-env win "par-spacing" answer mode)
                '("plain" "quanjiao" "banjiao" "hangmobanjiao" "kaiming")
                (window-get-env win "par-spacing" mode) "10em"))
        (item ====== ======)
        (item (text "Intercharacter stretching:")
          (enum (window-set-env win "par-kerning-stretch" answer mode)
                (cons-new (window-get-env win "par-kerning-stretch" mode)
                          '("auto" "tolerant"
                            "0" "0.02" "0.05" "0.1" "0.2" "0.5" "1" ""))
                (window-get-env win "par-kerning-stretch" mode) "10em"))
        (item (text "Intercharacter compression:")
          (enum (window-set-env win "par-kerning-reduce" answer mode)
                (cons-new (window-get-env win "par-kerning-reduce" mode)
                          '("auto"
                            "0" "0.01" "0.02" "0.03" "0.05" "0.1" "0.2" ""))
                (window-get-env win "par-kerning-reduce" mode) "10em"))
        (item (text "Character expansion:")
          (enum (window-set-env win "par-expansion" answer mode)
                (cons-new (window-get-env win "par-expansion" mode)
                          '("auto" "tolerant"
                            "0" "0.01" "0.02" "0.05" "0.1" "0.2" ""))
                (window-get-env win "par-expansion" mode) "10em"))
        (item (text "Character contraction:")
          (enum (window-set-env win "par-contraction" answer mode)
                (cons-new (window-get-env win "par-contraction" mode)
                          '("auto" "tolerant"
                            "0" "0.01" "0.02" "0.05" "0.1" "0.2" ""))
                (window-get-env win "par-contraction" mode) "10em"))
        (item ====== ======)
        (item (text "Use margin kerning:")
          (toggle (window-set-env win "par-kerning-margin"
                                  (if answer "true" "false") mode)
                  (== (window-get-env win "par-kerning-margin" mode)
                      "true")))))
    ======
    (assuming (not (tool-ref (list win mode "advanced paragraph")))
      (division "discrete"
        ("Show advanced settings"
         (begin
           (tool-set (list win mode "advanced paragraph") #t)
           (refresh-now "paragraph tool")
           (update-menus)))))      
    (assuming (tool-ref (list win mode "advanced paragraph"))
      (division "discrete"
        ("Hide advanced settings"
         (begin
           (tool-set (list win mode "advanced paragraph") #f)
           (refresh-now "paragraph tool")
           (update-menus)))))))

(tm-widget (texmacs-side-tool win tool)
  (:require (== tool "format paragraph"))
  (division "title"
    (text "This paragraph format"))
  (centered
    (dynamic (paragraph-basic-tool win :paragraph))
    ======))

(tm-widget (texmacs-side-tool win tool)
  (:require (== tool "document paragraph"))
  (division "title"
    (text "Global paragraph format"))
  (centered
    (dynamic (paragraph-basic-tool win :global))
    ======))
