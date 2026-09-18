gemm_sve_f8f32
==============

Draft for fp8 (E4M3) -> fp32 dot products with SVE FDOT (FEAT_FP8DOT4)

QEMU setup for FEAT_FP8DOT4
---------------------------

curl -LO https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-arm64.img
qemu-img resize ubuntu-26.04-server-cloudimg-arm64.img 20G

--- cloud-init seed (user: ubuntu) 
mkdir -p seed
cat > seed/user-data <<'CLOUD'
#cloud-config
password: dev
chpasswd: { expire: false }
ssh_pwauth: true
CLOUD
cat > seed/meta-data <<'CLOUD'
instance-id: fp8vm
local-hostname: fp8vm
CLOUD
hdiutil makehybrid -iso -joliet -default-volume-name cidata -o seed.iso seed

--- start (login: ubuntu / dev, ssh -p 2222 ubuntu@localhost)
qemu-system-aarch64 \
  -M virt -accel tcg -cpu max,sve-max-vq=1 \
  -smp 4 -m 4G \
  -bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
  -drive if=virtio,format=qcow2,file=ubuntu-26.04-server-cloudimg-arm64.img \
  -drive if=virtio,format=raw,file=seed.iso \
  -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
  -nographic

--- copy data
scp -P 2222 driver.c ubuntu@localhost:

--- connect
ssh -p 2222 ubuntu@localhost