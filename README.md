# Описание
Здесь находятся **скрипты** для автоматизации различных задач в [RouterOS](https://mikrotik.com/software) на оборудовании [MikroTik](https://mikrotik.com/aboutus). Как правило они запускаются через встроенный планировщик задач или по событию.

- `backup-system-config.rsc` - Резервное копирование конфигурации и прошивки в папку.
- `detect-and-send-wol.rsc` - Обнаружение и отправка WOL пакета для IPv4 и IPv6.
- `disable-wifi-5g-interfaces.rsc` - Отключение всех Wi-Fi 5 GHz интерфейсов.
- `disable-wifi-5g-interfaces.rsc` - Включение всех Wi-Fi 5 GHz интерфейсов.
- `reconnect-if-gray-address.rsc` - Переподключение к Интернет при получении серого IPv4.
- `reconnect-internet-interfaces.rsc` - Переподключение всех Интернет интерфейсов.
- `update-discovery-dns.rsc` - Обновление адреса Discovery DNS для IPv6.
- `update-dns-record.rsc` - Синхронизация DNS с DHCP, IPsec, WireGuard и т.д.
- `update-or-reboot-system.rsc` - Обновление или перезагрузка устройства.