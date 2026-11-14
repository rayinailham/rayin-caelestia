#!/usr/bin/env bash

notify() {
    notify-send -a Camera -i camera-web-symbolic -u "$1" 'Kamera' "$2"
}

if [[ -d /sys/module/uvcvideo ]]; then
    if pkexec /usr/bin/modprobe -r uvcvideo; then
        notify normal 'OFF — driver uvcvideo dinonaktifkan'
    else
        notify critical 'Gagal menonaktifkan kamera. Tutup Discord/aplikasi kamera, lalu coba lagi.'
        exit 1
    fi
else
    if ! pkexec /usr/bin/modprobe uvcvideo; then
        notify critical 'Gagal mengaktifkan driver uvcvideo.'
        exit 1
    fi

    sleep 1
    if compgen -G '/dev/video*' > /dev/null; then
        notify normal 'ON — kamera siap dipakai'
    else
        notify critical 'Driver ON, tetapi webcam belum terdeteksi. Tekan tombol privacy camera HP, lalu cek pengaturan kamera di BIOS.'
    fi
fi
