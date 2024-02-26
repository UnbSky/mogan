
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : gs.scm
;; DESCRIPTION : Ghostscript Binary plugin
;; COPYRIGHT   : (C) 2024  Darcy Shen
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (binary gs))

(define (gs-binary-candidates)
  (cond ((os-macos?)
         (list "/opt/homebrew/Cellar/ghostscript/1*/bin/gs"
               "/usr/local/Cellar/ghostscript/1*/bin/gs"))
        ((os-win32?)
         (list "C:\\Program Files*\\gs\\gs*\\bin\\gswin*c.exe"))
        (else
         (list "/usr/bin/gs"))))

(tm-define (find-binary-gs)
  (:synopsis "Find the url to the gs binary, return (url-none) if not found")
  (with u (or (list-find (gs-binary-candidates)
                (lambda (x) (url-exists? (url-resolve x "r"))))
              (url-resolve-in-path "gs"))
    (url-resolve u "r")))

(tm-define (has-binary-gs?)
  (not (url-none? (find-binary-gs))))

(tm-define (version-binary-gs)
  (with ret (check-stdout (string-append (url->system (find-binary-gs)) " --version"))
    ret))

(tm-define (gs-ps-image-size u)
  (let* ((out (check-stderr (string-append
           (url->system (find-binary-gs))
           " -dQUIET "
           " -dNOPAUSE "
           " -dBATCH "
           " -dSAFER "
           " -sDEVICE=bbox "
           (url->system u))))
         (l (filter (lambda (x) (string-starts? x "%%BoundingBox: "))
                (string-split out #\newline)))
         (box (and (> (length l) 0)
               (string-drop (car l) (length "%%BoundingBox: "))))
         (fbox (and (> (length box) 0) (map string->float (string-split box #\space)))))
    (and (== (length fbox) 4)
         (list (floor (first fbox)) ;; x1
               (floor (second fbox)) ;; y1
               (ceiling (third fbox)) ;; x2
               (ceiling (fourth fbox)))))) ;; y2

(tm-define (gs-eps-to-pdf from opts)
  (let* ((to (assoc-ref opts 'dest))
         (box (gs-ps-image-size from))
         (w (number->string (- (third box) (first box))))
         (h (number->string (- (fourth box) (second box))))
         (offset-x (number->string (- (first box))))
         (offset-y (number->string (- (second box))))
         (gs-inline
           (string-append
             "<< /PageSize [ " w " " h " ] >> setpagedevice gsave "
             offset-x " " offset-y " translate "
             "1 1 scale"))
         (cmd
           (string-append
             (url->system (find-binary-gs))
             " -dQUIET "
             " -dNOPAUSE "
             " -dBATCH "
             " -dSAFER "
             " -sDEVICE=pdfwrite "
             " -dAutoRotatePages=/None "
             " -dCompatibilityLevel=1.4 "
             (string-append " -sOutputFile=" (url->system to) " ")
             (string-append " -c " (string-quote gs-inline))
             (string-append " -f " (url->system from) " ")
             (string-append " -c " (string-quote " grestore ")))))
    (debug-message "io" (string-append "call: " cmd "\n"))
    (system cmd)))

(tm-define (gs-convert x opts)
  ;; many options for pdf->ps/eps see http://tex.stackexchange.com/a/20884
  ;; this one does a better rendering than pdf2ps (also based on gs):
  (let* ((dest (assoc-ref opts 'dest))
         (gs (url->system (gs-binary))))
    (system-2 (string-append gs " -q -dNOCACHE -dUseCropBox -dNOPAUSE -dBATCH -dSAFER -sDEVICE=eps2write -sOutputFile=") dest x))
  ;; problem: 
  ;; eps2write available starting with gs  9.14 (2014-03-26)
  ;; epswrite removed in gs 9.16 (2015-03-30)
  )

(tm-define (pdf-file->gs-raster x opts)
  (let* ((dest (assoc-ref opts 'dest))
         (res (get-raster-resolution opts))
         (gs (url->system (gs-binary))))
    (evaluate-system (list gs "-dBATCH" "-dNOPAUSE" "-dQUIET" "-dSAFER"
                           "-dNOPROMPT" "-sDEVICE=pngalpha"
                           (string-append "-r" res)
                           (string-append "-sOutputFile="
                                          (url-concretize dest))
                           (url-concretize x)) '() '() '(1 2))
    (if (url-exists? dest) dest #f)))
