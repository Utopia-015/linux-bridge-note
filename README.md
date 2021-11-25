# 配置Linux网桥
本文仅使用 [iproute2](http://www.policyrouting.org/iproute2.doc.html) 工具包
### 创建网桥
1. 创建一个网桥并设置其状态为已启动：
```
# ip link add name <bridge_name> type bridge
# ip link set dev <bridge_name> up
```
2. 给网桥配置 IP 地址：
```
# ip addr add dev <bridge_name> <address>
```
3. 添加网络端口（物理或虚拟）到网桥中，要求先将该端口设置为混杂模式并启动该端口：
```
# ip link set dev <ifname> promisc on
# ip link set dev <ifname> up
```
4. 把该端口添加到网桥中，再将其所有者设置为 bridge_name 就完成了配置：
```
# ip link set dev <ifname> master <bridge_name>
```
5. 要显示现存的网桥及其关联的端口，可以用 bridge 工具（它也是 iproute2 的组成部分）。
```
# bridge link show
```
6. 若要删除网桥，应首先移除它所关联的所有端口，同时关闭端口的混杂模式并关闭端口以将其恢复至原始状态。
```
# ip link set <ifname> promisc off
# ip link set <ifname> down
# ip link set dev <ifname> nomaster
```
7. 当网桥的配置清空后就可以将其删除：
```
# ip link delete <bridge_name> type bridge
```
### 创建虚拟tap接口并桥接到网桥
1. 创建一个tap接口：
```
# ip tap add name <ifname> mode tap
```
2. 将该端口设置为混杂模式并启动该端口：
```
# ip link set dev <ifname> promisc on
# ip link set dev <ifname> up
```
3. 把该端口添加到网桥中，再将其所有者设置为 bridge_name 就完成了配置：
```
# ip link set dev <ifname> master <bridge_name>
```
4. 要显示现存的网桥及其关联的端口，可以用 bridge 工具（它也是 iproute2 的组成部分）。
```
# bridge link show
```
5. 默认tap接口速率为 100Mbps，改为 1Gbps：
```
# bridge link set dev <ifname> cost 4
```
### 配置网桥的路由
1. 添加 default 路由设备为网桥
```
# ip route add default via <gateway> dev <bridge_name>
```
### 参考文档

