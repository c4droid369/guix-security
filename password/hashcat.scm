(define-module (password hashcat)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)

  #:use-module (gnu packages compression)
  #:use-module (gnu packages digest)
  #:use-module (gnu packages opencl))
(define-public hashcat
  (package
    (name "hashcat")
    (version "6.2.6")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://hashcat.net/files/hashcat-" version
                                  ".tar.gz"))
              (sha256
               (base32
                "0akv1cgbmwyw8h8zbw5w5ixh92y95sdadh8qiz60hjgkpivi0pmj"))
              (modules '((guix build utils)))
              (snippet
               #~(for-each delete-file-recursively
                           '("deps/zlib" "deps/xxHash" "deps/OpenCL-Headers")))))
    (inputs (list minizip opencl-headers xxhash zlib))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f
           #:make-flags #~(list (string-append "PREFIX=" #$output)
                                (string-append "AR=" #$(ar-for-target))
                                (string-append "CC=" #$(cc-for-target))
                                (string-append "USE_SYSTEM_ZLIB=1")
                                (string-append "USE_SYSTEM_OPENCL=1")
                                (string-append "USE_SYSTEM_XXHASH=1"))
           #:phases #~(modify-phases %standard-phases
                        (add-after 'unpack 'fix-reproducibility
                          (lambda _
                            (substitute* "src/Makefile"
                              (("\\$\\(shell date \\+%s\\)")
                               "0"))))
                        (delete 'configure))))
    (home-page "https://hashcat.net/hashcat/")
    (synopsis "Advanced password recovery utility")
    (description
     "Hashcat is an password recovery utility, supporting five
unique modes of attack for over 200 highly-optimized hashing algorithms.
Hashcat currently supports CPUs, GPUs, and other hardware accelerators on
Linux, Windows, and macOS, and has facilities to help enable distributed
password cracking.")
    (license license:expat)))
