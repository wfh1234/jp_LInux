# -*- coding: utf-8 -*-

import openpyxl
from datetime import datetime
import pytz
import psutil
import os
import time
import json
import re
from scp import SCPClient
import paramiko
import socket

import argparse

parser = argparse.ArgumentParser(description='jp script')
parser.add_argument('-o', '--order_no', default="test", type=str, help='订单号', required=True)
args = parser.parse_args()


class Config(object):
    @staticmethod
    def get_config_data():
        with open('./config.json', 'r') as f:
            return json.load(f)


class JPServerDetection(object):
    def __init__(self):
        config = Config()
        config_data = config.get_config_data()
        self.server_password = config_data.get('server_password', '')
        self.remote_path = config_data.get('remote_path', '')
        self.remote_host = config_data.get('remote_host', '0.0.0.0')
        self.remote_port = config_data.get('remote_port', 22)
        self.remote_username = config_data.get('remote_username', 'root')
        self.remote_password = config_data.get('remote_password', '111111')

        base_path = config_data.get('shell_path', '/')
        self.cpu_shell = '{}{}'.format(base_path, config_data.get('cpu_shell', 'cpu_info.sh'))
        self.ipmi_shell = '{}{}'.format(base_path, config_data.get('ipmi_shell', 'ipmi_info.sh'))
        self.mem_shell = '{}{}'.format(base_path, config_data.get('mem_shell', 'mem_info.sh'))
        self.raid1_shell = '{}{}'.format(base_path, config_data.get('raid1_shell', 'raid_info1.sh'))
        self.raid2_shell = '{}{}'.format(base_path, config_data.get('raid2_shell', 'raid_info2.sh'))
        self.disk_shell = '{}{}'.format(base_path, config_data.get('disk_shell', 'disk_info.sh'))
        self.disk2_shell = '{}{}'.format(base_path, config_data.get('disk2_shell', 'disk_info2.sh'))
        self.fan_shell = '{}{}'.format(base_path, config_data.get('fan_shell', 'fan_info.sh'))
        self.power_shell = '{}{}'.format(base_path, config_data.get('power_shell', 'power_info.sh'))
        self.bios_shell = '{}{}'.format(base_path, config_data.get('bios_shell', 'bios_info.sh'))
        self.motherboard_shell = '{}{}'.format(base_path, config_data.get('motherboard_shell', 'motherboard_info.sh'))
        self.network1_shell = '{}{}'.format(base_path, config_data.get('network1_shell', 'network_info1.sh'))
        self.usb_shell = '{}{}'.format(base_path, config_data.get('usb_shell', 'usb_info.sh'))
        self.nvidia_shell = '{}{}'.format(base_path, config_data.get('nvidia_shell', 'nvidia_info.sh'))
        self.network_test_shell = '{}{}'.format(base_path, config_data.get('network_test_shell', 'network_info3.sh'))
        self.fc_hba_shell = '{}{}'.format(base_path, config_data.get('fc_hba_shell', 'fc_hba_info.sh'))
        self.system_shell = '{}{}'.format(base_path, config_data.get('system_shell', 'system_info.sh'))
        self.cdrom_shell = '{}{}'.format(base_path, config_data.get('cdrom_shell', 'cdrom_info.sh'))
        self.init_software_shell = '{}{}'.format(base_path, config_data.get('init_software_shell', 'jp_info.sh'))
        self.graphics_shell = '{}{}'.format(base_path, config_data.get('graphics_shell', 'graphics_info.sh'))
        self.nvidia2_shell = '{}{}'.format(base_path, config_data.get('nvidia2_shell', 'nvidia_info2.sh'))
        self.network4_shell = '{}{}'.format(base_path, config_data.get('network4_shell', 'network_info4.sh'))
        self.audio_shell = '{}{}'.format(base_path, config_data.get('audio_shell', 'audio_info.sh'))

    @staticmethod
    def os_popen(command):
        """运行linux命令"""
        return os.popen(command)

    def init_software(self):
        """预安装软件"""
        self.os_popen('echo {} | sudo -S sh {}'.format(self.server_password, self.init_software_shell))

    def get_sys_info(self):
        """获取操作系统信息"""
        # # 操作系统名称
        sys_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.system_shell))
        sys_data = sys_info.read().strip()

        return [i.strip() for i in sys_data.split('*')]

    def get_cpu_info(self):
        """获取cpu信息"""
        cpu_info = self.os_popen('echo {} | sudo -S {} | grep "cpu_info:"'.format(self.server_password, self.cpu_shell))
        cpu_data = cpu_info.read().strip()

        res = [i.split('cpu_info:')[1].strip() for i in cpu_data.split('\n')]
        cpu_str = ''
        for i in res:
            cpu_data = [j.strip() for j in i.split('*')]
            cpu_str += '名称：{}，版本：{}，核心数：{}，针脚数：{}\n'.format(*cpu_data)

        return cpu_str.strip()

    def get_ipmi_info(self):
        """获取ipmi信息"""
        ipmi_info = self.os_popen('echo {} | sudo -S {} | grep "ipmi_info:"'.format(
            self.server_password, self.ipmi_shell))
        ipmi_data = ipmi_info.read().strip()
        try:
            ipmi_list = [i.strip() for i in ipmi_data.split('ipmi_info:')[1].split('*')]
        except Exception as e:
            print('获取ipmi信息失败')
            # print(e)
            return None
        if len(ipmi_list) != 4:
            return None
        return ipmi_list

    def get_mem_info(self):
        """获取内存信息"""
        mem_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.mem_shell))
        mem_data = mem_info.read().strip()
        mem_list = mem_data.split('\n')
        mem_str = ''
        mem_sum = 0
        unit = 'GB'
        for mem in mem_list:
            single_mem = [i.strip() for i in mem.split('\t')]

            if len(single_mem) != 6:
                return None

            mem_str += '制造商：{}，内存条：{}，容量：{}，速度：{}， 规格：{}，PN号：{}\n'.format(*single_mem)
            mem_sum += int(single_mem[2].strip()[:-2])
            unit = single_mem[2].strip()[-2:]

        return {
            'mem_detail': mem_str.strip(),
            'mem_sum': '{} {}'.format(round(float(mem_sum), 1), unit),
            'mem_num': len(mem_list)
        }

    def get_raid_info(self):
        """获取raid信息"""
        raid_info = self.os_popen('echo {} | sudo -S {} | grep "raid_info:"'.format(
            self.server_password, self.raid1_shell))
        raid_data = raid_info.read().strip()
        raid_list = [i.strip() for i in raid_data.split('raid_info:')[-1].split('*')]
        if len(raid_list) != 12:
            return list('无' * 12)
        new_list = list()
        for i in raid_list:
            if not i:
                i = '无'
            new_list.append(i)
        return new_list

    def get_raid_disk_info(self):
        """接RAID卡物理磁盘"""
        raid_disk_info = self.os_popen('echo {} | sudo -S {}'.format(
            self.server_password, self.raid2_shell))
        raid_disk_data = raid_disk_info.read().strip()
        disk_str = ''
        for i in raid_disk_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            if len(disk_list) != 5:
                return '无'
            disk_str += 'slot位置：{}，硬盘型号：{}，接口类型：{}，容量：{}，硬盘状态：{}\n'.format(*disk_list)

        return disk_str.strip()

    def get_disk_info(self):
        """硬盘信息"""
        disk_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.disk_shell))
        disk_data = disk_info.read().strip()
        disk_str = ''
        for i in disk_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            if len(disk_list) == 4:
                disk_list.append('无')
            else:
                if len(disk_list) != 5:
                    return '无'
            disk_str += '型号：{}，固件版本：{}，盘符：{}，容量：{}，序列号：{}\n'.format(*disk_list)
        return disk_str.strip()

    def get_disk2_info(self):
        disk2_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.disk2_shell))
        disk2_data = disk2_info.read().strip()
        if not disk2_data:
            return '无'

        disk_str = ''
        for i in disk2_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            while len(disk_list) < 4:
                disk_list.append('无')
            if len(disk_list) > 4:
                return '无'
            new_disk_list = [disk_list[1], disk_list[0], disk_list[2], disk_list[3]]
            disk_str += '盘符：{:<20}大小：{:<20}文件系统：{:<20}挂载点：{}\n'.format(*new_disk_list)

        return disk_str.strip() or '无'

    def get_fan_info(self):
        """获取风扇信息"""
        fan_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.fan_shell))
        fan_data = fan_info.read().strip()
        if not fan_data:
            print('---please input fan info---')
            while True:
                print('please input fan amount, require positive integer')
                fan_amount = input('fan amount:')
                try:
                    fan_amount = int(fan_amount)
                except ValueError:
                    print('fan amount require positive integer')
                    continue
                if fan_amount <= 0:
                    print('fan amount require positive integer')
                    continue
                break
            while True:
                print('please input fan status: 0 or 1，0 is ok, 1 is fail')
                fan_status = input('fan status:')
                if fan_status not in ['0', '1']:
                    print('please input 0 or 1，0 is ok, 1 is fail')
                    continue
                break
            return '风扇总数量：{}，状态：{}\n'.format(fan_amount, {'0': '合格', '1': '不合格'}.get(fan_status))

        fan_list = fan_data.split('\n')
        fan_str = '风扇总数量：{}\n'.format(len(fan_list))
        for i in fan_list:
            fan_list = [j.strip() for j in i.replace('\t', ' ').split('  ') if j.strip()]
            fan_str += '风扇：{}，转速：{}，状态：{}\n'.format(*fan_list)

        return fan_str.strip()

    def get_power_info(self):
        power_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.power_shell))
        power_data = power_info.read().strip()
        if not power_data:
            print('---please input power info---')
            while True:
                print('please input power amount, require positive integer')
                power_amount = input('power amount:')
                try:
                    power_amount = int(power_amount)
                except ValueError:
                    print('fan amount require positive integer')
                    continue
                if power_amount <= 0:
                    print('fan amount require positive integer')
                    continue
                break

            while True:
                print(
                    'please input power manufacturer: [0][1][2][3]，0 is Supermicro, 1 is DELTA, 2 is AcBel, 3 is Great Wall')
                power_manufacturer = input('power manufacturer:')
                if power_manufacturer not in ['0', '1', '2', '3']:
                    continue
                break

            while True:
                print('please input power capacity, require positive integer, from 200 to 2200')
                power_capacity = input('power capacity:')
                try:
                    power_capacity = int(power_capacity)
                except ValueError:
                    print('power capacity require positive integer')
                    continue
                if power_capacity > 2200 or power_capacity < 200:
                    print('power capacity require positive integer, from 200 to 2200')
                    continue
                break

            while True:
                print('please input power status: 0 or 1，0 is ok, 1 is fail')
                fan_status = input('power status:')
                if fan_status not in ['0', '1']:
                    print('please input 0 or 1，0 is ok, 1 is fail')
                    continue
                break

            power_dict = {'0': 'Supermicro', '1': 'DELTA', '2': 'AcBel', '3': 'Great Wall'}
            return '电源总数量：{}，品牌：{}，功率：{} W，状态：{}'.format(
                power_amount,
                power_manufacturer,
                power_dict.get(power_capacity),
                {'0': '合格', '1': '不合格'}.get(fan_status)
            )

        power_list = power_data.split('\n\t')
        man_list, revision_list, capacity_list, status_list = list(), list(), list(), list()
        for i in power_list:
            if i.startswith('Manufacturer:'):
                man_list.append(i.split('Manufacturer:')[-1].strip())
            elif i.startswith('Revision:'):
                revision_list.append(i.split('Revision:')[-1].strip())
            elif i.startswith('Max Power Capacity:'):
                capacity_list.append(i.split('Max Power Capacity:')[-1].strip())
            elif i.startswith('Status:'):
                status_list.append(i.split('Status:')[-1].strip())

        power_str = ''
        for value in zip(man_list, revision_list, capacity_list, status_list):
            value = [j.split(':')[-1].strip() for j in value]
            power_str += '品牌：{}，版本：{}，功率：{}，状态：{}\n'.format(*value)
        return power_str.strip()

    def get_bios_info(self):
        bios_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.bios_shell))
        bios_data = bios_info.read().strip()
        bios_list = bios_data.split('*')
        return {
            'version': bios_list[0].split(':')[-1].strip(),
            'release_date': bios_list[1].split(':')[-1].strip(),
            'current_time': bios_list[2].strip()
        }

    def get_motherboard_info(self):
        board_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.motherboard_shell))
        board_data = board_info.read().strip()
        board_list = board_data.split('*')
        return {
            'manufacturer': board_list[0].split(':')[-1].strip(),
            'product_name': board_list[1].split(':')[-1].strip(),
            'serial_number': board_list[2].split(':')[-1].strip()
        }

    def get_network_info(self):
        network_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.network1_shell))
        network_data = network_info.read().strip().split('\n')
        new_network_data = [i for i in network_data if i]
        network_str = ''
        for i in new_network_data:
            new_list = [j.strip() for j in i.split('*') if j.strip()]
            network_str += '速度：{}，MAC地址：{}，网口名称：{}，网口芯片：{}\n'.format(*new_list)

        return network_str.strip() or '无'




    def get_independent_network_info(self):
        """获取独立网卡信息"""
        network_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.network4_shell))
        network_data = network_info.read().strip().split('\n')
        new_network_data = [i for i in network_data if i]
        network_str = ''
        for i in new_network_data:
            network_list = [j.strip() for j in i.split('*') if j.strip()]
            network_str += 'PCI-E插槽信息：{}，型号：{}\n'.format(*network_list)

        return network_str.strip() or '无'

    def get_usb_info(self):
        usb_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.usb_shell))
        usb_data = usb_info.read().strip()
        usb_list = [i for i in usb_data.split('\n') if i]

        usb_str = ''
        for i in usb_list:
            usb_str += 'USB接口：{}，测试结果：{}\n'.format(*[j.strip() for j in i.split(' ')])

        return usb_str.strip() or '无'

    def get_nvidia_info(self):
        """独立显卡"""
        nvidia_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.nvidia_shell))
        data = nvidia_info.read().strip().split('\n')
        new_data = [i for i in data if i]
        model_list, pci_e_list, vbios_list, image_list = list(), list(), list(), list()
        for i in new_data:
            values = i.split(':')
            if values[0].strip() == 'model':
                model_list.append(values[1].strip())
            elif values[0].strip() == 'pci-e':
                pci_e_list.append(values[1].strip())
            elif values[0].strip() == 'vbios':
                vbios_list.append(values[1].strip())
            elif values[0].strip() == 'image':
                image_list.append(values[1].strip())

        data_str = ''
        for i in zip(model_list, pci_e_list, vbios_list, image_list):
            data_str += '型号：{}，PCI-E位置：{}，VBIOS版本：{}，Image版本：{}\n'.format(*i)

        return data_str.strip() or '无'

    def get_nvidia_info2(self):
        """nvidia-smi信息"""
        nvidia_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.nvidia2_shell))
        return nvidia_info.read().strip() or '无'

    def get_graphics_info(self):
        """集成显卡"""
        graphics_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.graphics_shell))
        return graphics_info.read().strip() or '无'

    def get_network_test_info(self):
        network_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.network_test_shell))
        network_data = network_info.read().strip().split('\n')
        new_network_data = [i for i in network_data if i]
        data_str = ''
        for i in new_network_data:
            single_data = [j for j in i.strip().split(' ') if j]
            data_str += '网口名称：{}，链接速度：{}，测试结果：{}\n'.format(*single_data)

        return data_str.strip() or '无'

    def get_fc_hba_info(self):
        """hba卡信息"""
        hba_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.fc_hba_shell))
        hba_data = hba_info.read().strip().split('\n')
        new_hba_data = [i for i in hba_data if i]
        hba_data_str = ''
        for i in new_hba_data:
            single_data = [j.strip() for j in i.strip().split(':') if j]
            hba_data_str += '型号：{}，规格: {}，序列号：{}\n'.format(*single_data)

        return hba_data_str.strip() or '无'

    def get_cdrom_info(self):
        """光驱"""
        cdrom_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.cdrom_shell))
        return cdrom_info.read().strip() or '无'

    def get_audio_info(self):
        """声卡"""
        audio_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.audio_shell))
        return audio_info.read().strip() or '无'

    def scp_report(self, local_path, target_path):
        """拷贝报告到远程服务器"""
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy)

        try:
            ssh_client.connect(
                self.remote_host,
                self.remote_port,
                self.remote_username,
                self.remote_password,
                timeout=5)
        except socket.gaierror:
            print(u'ssh连接{}:{}服务器失败，请确认服务器可以连通或者参数配置是否正确'.format(self.remote_host, self.remote_port))
            return
        except paramiko.ssh_exception.NoValidConnectionsError:
            print(u'ssh无法连接服务器：{}的端口：{}，请检查服务器端口或者参数配置是否正确'.format(self.remote_host, self.remote_port))
            return
        except paramiko.ssh_exception.AuthenticationException:
            print(u'ssh连接服务器{}:{}的用户名或密码错误，请检查参数配置是否正确'.format(self.remote_host, self.remote_port))
            return
        except Exception as e:
            print(u'ssh连接服务器的其他错误：{}'.format(e))
            return
        scp_client = SCPClient(ssh_client.get_transport(), socket_timeout=15.0)

        try:
            scp_client.put(local_path, target_path)
        except FileNotFoundError as e:
            # print(e)
            print("系统找不到指定的报告文件：" + local_path)
        ssh_client.close()

    def run(self):
        wb = openpyxl.load_workbook('report_template1.xlsx')
        sheet = wb['Sheet1']

        # 预安装软件
        self.init_software()

        # 订单号
        sheet['C3'].value = args.order_no

        # 操作系统
        # 操作系统名称及版本号/内核版本/计算机类型/计算机的网络名称/操作系统内核
        sys_info = self.get_sys_info()
        # for index, value in enumerate(sys_info):
        #     sheet['c%s' % str(4 + index)].value = value or '无'

        # 主板信息
        motherboard_info = self.get_motherboard_info()
        # 主板品牌
        manufacture = motherboard_info.get("manufacture")
        product_name = motherboard_info.get("product_name")
        serial_list = motherboard_info.get("serial_list")

        sheet['C7'].value = f'主板品牌:{manufacture}  主板型号：{product_name}  主板序列号：{serial_list}'
        # 主板型号
        # sheet['D8'].value = motherboard_info.get('product_name', '无')
        # # 主板序列号
        # sheet['D9'].value = motherboard_info.get('serial_number', '无')

        # # bios信息
        bios_info = self.get_bios_info()
        version=bios_info.get('version')
        data=bios_info.get('')



        # # bios版本
        # sheet['D10'].value = bios_info.get('version', '无')
        # # BIOS创建日期
        # sheet['D11'].value = bios_info.get('release_date', '无')
        # # BIOS时间和日期
        # sheet['D12'].value = bios_info.get('current_time', '无')
        #
        # # ipmi
        # ipmi_info = self.get_ipmi_info()
        # if ipmi_info:
        #     # IP地址   IP获取方式    MAC地址   固件版本
        #     for i, j in enumerate(ipmi_info):
        #         sheet['D{}'.format(13 + i)].value = j or '无'
        #
        # # cpu型号
        # sheet['D17'].value = self.get_cpu_info()
        #
        # # 内存信息
        # mem_info = self.get_mem_info()
        # if not mem_info:
        #     print('获取内存信息失败，请检验shell脚本配置')
        # else:
        #     # 内存总容量
        #     mem_num = 18
        #     sheet['D{}'.format(mem_num)].value = mem_info.get('mem_sum')
        #     # 内存条数量
        #     sheet['D{}'.format(mem_num + 1)].value = mem_info.get('mem_num')
        #     # 各内存条详情
        #     sheet['D{}'.format(mem_num + 2)].value = mem_info.get('mem_detail')
        #
        # # 硬盘信息
        # sheet['D21'].value = self.get_disk_info()
        # # 分区信息
        # sheet['D22'].value = self.get_disk2_info()
        #
        # # 显卡
        # # 集显信息
        # sheet['D23'].value = self.get_graphics_info()
        # # 独立显卡信息
        # sheet['D24'].value = self.get_nvidia_info()
        # # nvidia-smi信息
        # sheet['D25'].value = self.get_nvidia_info2()
        #
        # # 电源信息
        # sheet['D26'].value = self.get_power_info()
        #
        # # usb信息
        # sheet['D27'].value = self.get_usb_info()
        #
        # # 网口信息
        # sheet['D28'].value = self.get_network_info()
        # sheet['D29'].value = self.get_independent_network_info()
        # sheet['D30'].value = self.get_network_test_info()
        #
        # # raid信息
        # # Firmware 版本/RAID 状态/RAID 级别/RAID 容量/RAID卡插PCI-E槽信息/RAID卡序列号/RAID卡型号/缓存容量/BBU电池状态/写入模式/接RAID卡物理磁盘
        # raid_info = self.get_raid_info()
        # for i, value in enumerate(raid_info):
        #     sheet['D{}'.format(i + 31)].value = value
        # sheet['D43'].value = self.get_raid_disk_info()
        #
        # # FC HBA卡信息
        # sheet['D44'].value = self.get_fc_hba_info()
        #
        # # 风扇信息
        # sheet['D45'].value = self.get_fan_info()
        #
        # # 光驱
        # sheet['D46'].value = self.get_cdrom_info()
        # # 声卡
        # sheet['D47'].value = self.get_audio_info()

        file_path = u'./reports/{}.xlsx'.format(args.order_no)
        wb.save(file_path)

        # self.scp_report(local_path=file_path, target_path=self.remote_path)

    # def test_shell(self):
    #     sys = self.get_sys_info()
    #     cpu = self.get_cpu_info()
    #     ipmi = self.get_ipmi_info()
    #     mem = self.get_mem_info()
    #     raid = self.get_raid_info()
    #     raid_disk = self.get_raid_disk_info()
    #     disk = self.get_disk_info()
    #     disk2 = self.get_disk2_info()
    #     fan = self.get_fan_info()
    #     power = self.get_power_info()
    #     bios = self.get_bios_info()
    #     motherboard = self.get_motherboard_info()
    #     network = self.get_network_info()
    #     independent = self.get_independent_network_info()
    #     usb = self.get_usb_info()
    #     nvidia1 = self.get_nvidia_info2()
    #     nvidia2 = self.get_nvidia_info2()
    #     graphics = self.get_graphics_info()
    #     networktest = self.get_network_test_info()
    #     hba = self.get_fc_hba_info()
    #     cdrom = self.get_cdrom_info()
    #     audio = self.get_audio_info()
    #     # scp_report = self.scp_report()
    #     print("系统信息:", sys, "\n")
    #     print("cpu信息：", cpu, "\n")
    #     print("ipmi信息", ipmi, '\n')
    #     print("内存信息", mem, '\n')
    #     print('raid信息：', raid, '\n')
    #     print("raid物理磁盘：", raid_disk, '\n')
    #     print("硬盘信息：", disk, '\n')
    #     print("disk2:", disk2, '\n')
    #     print("风扇信息：", fan, '\n')
    #     print("电源信息：", power, '\n')
    #     print("bios:", bios, '\n')
    #     print('motherboard:', motherboard, '\n')
    #     print('network:', network, '\n')
    #     print("独立网卡：", independent, '\n')
    #     print("usb信息：", usb, '\n')
    #     print("独立显卡：", nvidia1, '\n')
    #     print("独显smi:", nvidia2, '\n')
    #     print("集成显卡：", graphics, '\n')
    #     print("network:", networktest, '\n')
    #     print("hba卡信息：", hba, '\n')
    #     print("光驱：", cdrom, '\n')
    #     print("声卡：", audio, '\n')
    #     # print(scp_report)


if __name__ == '__main__':
    jp = JPServerDetection()
    jp.run()
