class UNITDevice {
  final String name;
  final String serverIp;
  final int serverPort;
  final String ftpHost;
  final int ftpPort;

  const UNITDevice({
    required this.name,
    required this.serverIp,
    required this.serverPort,
    required this.ftpHost,
    required this.ftpPort,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UNITDevice && name == other.name;

  @override
  int get hashCode => name.hashCode;

  // Taken from the official thermal app v3.0.30
  static const List<UNITDevice> devices = [
    UNITDevice(
      name: 'UTi730E',
      serverIp: "192.168.15.10",
      serverPort: 9527,
      ftpHost: "192.168.15.10",
      ftpPort: 9528,
    ),
    UNITDevice(
      name: 'UTi720E',
      serverIp: "192.168.16.10",
      serverPort: 9527,
      ftpHost: "192.168.16.10",
      ftpPort: 9528,
    ),
    UNITDevice(
      name: 'UTi320E',
      serverIp: '192.168.10.10',
      serverPort: 9527,
      ftpHost: '192.168.10.10',
      ftpPort: 9528,
    ),
    UNITDevice(
      name: 'UTi260E',
      serverIp: '192.168.11.10',
      serverPort: 9527,
      ftpHost: '192.168.11.10',
      ftpPort: 9528,
    ),
    UNITDevice(
      name: 'H16T',
      serverIp: '192.168.11.10',
      serverPort: 9527,
      ftpHost: '192.168.11.10',
      ftpPort: 9528,
    ),
  ];
}
