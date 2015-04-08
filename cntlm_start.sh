#!/bin/bash

ME=${0/*\//}

usage()
{
    cat <<EOF
Usage: $ME -u username -d domain -n NTLMv2hash -p password -s upstream_proxy -e noproxy
EOF
}

parse_args()
{
  while [ $# -gt 0 ]; do
    arg="${1}"; shift
    case "$arg" in
      -h|--help|-\?)
        usage
        exit 0
        ;;
      -u)
        argopts="${1}"; shift
        username="${argopts}"
        ;;
      -d)
        argopts="${1}"; shift
        domain="${argopts}"
        ;;
      -n)
        argopts="${1}"; shift
        passhash="${argopts}"
        echo ${passhash}
        ;;
      -p)
        argopts="${1}"; shift
        password="${argopts}"
        echo ${password}
        ;;
      -s)
        argopts="${1}"; shift
        proxy="${argopts}"
        ;;
      -e)
        argopts="${1}"; shift
        noproxy="${argopts}"
        ;;
      *)
        echo "${ME}: invalid option -- \`${arg}'" >&2
        echo "Try \`${ME} --help' for more information." >&2
        exit 1
        ;;
    esac
  done

if [ -z "$username" ]; then
    echo "username must be present"
    usage
    exit 1
else
    echo UserName $username >> /etc/cntlm.ini
fi

if [ -z "$domain" ]; then
    echo "domain must be present"
    usage
    exit 1
else
    echo Domain $domain >> /etc/cntlm.ini
fi

if [[ -z "$passhash" && -z "$password" ]] ; then
    echo "NTLM hash or password must be present"
    usage
    exit 1
elif [ ! -z "$passhash" ]; then
    echo $passhash
    echo PassNTLMv2 $passhash >> /etc/cntlm.ini
elif [ ! -z "$password" ]; then
    echo $password
    echo Password $password >> /etc/cntlm.ini
fi

if [ -z "$proxy" ]; then
    echo "proxy must be present"
    usage
    exit 1
else
    echo Proxy $proxy >> /etc/cntlm.ini
fi

if [ -z "$noproxy" ]; then
    echo "noproxy not present using defaults"
    noproxy="localhost, 127.0.0.*, 10.*, 192.168.*, *.${domain}"
else
    echo NoProxy $noproxy >> /etc/cntlm.ini
fi

echo Gateway yes >> /etc/cntlm.ini
echo Listen 3128 >> /etc/cntlm.ini

}

parse_args "${@}"

exec /usr/sbin/cntlm -v -f -U cntlm -c /etc/cntlm.ini

