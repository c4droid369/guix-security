(define-module (wifi aircrack-ng)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)

  #:use-module (gnu packages autotools)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages base)
  #:use-module (gnu packages tcl)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages compression))
(define-public aircrack-ng
  (package
    (name "aircrack-ng")
    (version "1.7")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://download.aircrack-ng.org/aircrack-ng-"
                           version ".tar.gz"))
       (sha256
        (base32 "1hsq1gwmafka4bahs6rc8p98yi542h9a502h64bjlygpr3ih99q5"))))
    (build-system gnu-build-system)
    (native-inputs
     (list autoconf automake libtool pkg-config which
           expect))
    (inputs
     (list `(,hwloc "lib")
           libgcrypt
           libnl
           libpcap
           ethtool
           pcre
           sqlite
           zlib))
    (arguments
     `(#:configure-flags
       (list "CFLAGS=-fcommon"
             "--with-experimental=yes"
             "--with-gcrypt")
       #:phases (modify-phases %standard-phases
                  (add-before 'bootstrap 'patch-evalrev
                    (lambda _
                      (substitute* "evalrev"
                        (("/bin/sh")
                         (which "sh")))))
                  (add-after 'build 'absolutize-tools
                    (lambda* (#:key inputs #:allow-other-keys)
                      (let ((ethtool (search-input-file inputs
                                                        "/sbin/ethtool")))
                        (substitute* "scripts/airmon-ng"
                          (("ethtool ")
                           (string-append ethtool " ")))))))))
    (home-page "https://www.aircrack-ng.org")
    (synopsis "Assess WiFi network security")
    (description
     "Aircrack-ng is a complete suite of tools to assess WiFi network
security.  It focuses on different areas of WiFi security: monitoring,
attacking, testing, and cracking.  All tools are command-line driven, which
allows for heavy scripting.")
    (license (list license:gpl2+ license:bsd-3))))
