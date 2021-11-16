# валидация ключей, путь к файлам, запуск скриптов + ответ
# два режима: проверить последовательность выполнения
#
# проверка чекера
# 1. проверка существования файла
# 2. проверка исполняемости файла
# 3. запуск с ключами (генерация и хранение ключей)
# 4. форматированный вывод (с цветом)

# Генерация ключей
# 1. генерация рандомный флага с префиксом test_
# 2. получение id от вывода скрипта put.py
# 3. запись к себе id:test_flag с префиксом test_
# 4. получение flag от вывода скрипта get.py
# 5. верефикация в словаре с префиксом test_
import subprocess
import os
import yaml
import uuid


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


class Logs:
    def success(self, *msg, **kwargs):
        print(*self.colored_msg(bcolors.OKGREEN, *msg), **kwargs)

    def info(self, *msg, **kwargs):
        print(*self.colored_msg(bcolors.OKBLUE, *msg), **kwargs)

    def warning(self, *msg, **kwargs):
        print(*self.colored_msg(bcolors.WARNING, *msg), **kwargs)

    def error(self, *msg, **kwargs):
        print(*self.colored_msg(bcolors.FAIL, *msg), **kwargs)

    @staticmethod
    def colored_msg(color, *msg):
        colored = list()
        for text in msg:
            colored.append(color + text + bcolors.ENDC)
        return colored


class FlagsStorage:
    def __init__(self):
        self.flags = list()

    def add_id_flag_pair(self, _id, flag):
        self.flags.append((_id, flag))

    @staticmethod
    def generate_flag():
        return "test_" + uuid.uuid4().hex.upper()


print_errors = False
logs = Logs()
flags_storage = FlagsStorage()

file_name = "admin-node/ad-ctf-paas-api/checker.yml"
scripts_dir = "admin-node/ad-ctf-paas-api/scripts/"
service_keys = [
    ["name", "cost", "hp", "put", "check"],
    ["name"]
]
executable_fields = ["put", "check"]

check_name_flag = False


def check_names(data: dict, names: list):
    global check_name_flag
    for field, data in data.items():
        for service in data:
            for key, values in service.items():
                if key not in names[0]:
                    check_name_flag = True
                    logs.error(f'Unsupported key "{key}" for field "{field}"')
                if isinstance(values, list):
                    check_names({key: values}, names[1])


def check_executable(data: dict):
    for service in data["services"]:
        for field in executable_fields:
            script_path = service.get(field)
            if script_path is not None:
                for i, file in enumerate(script_path, 1):
                    filename = file.get("name")
                    if filename is not None:
                        path = scripts_dir + filename
                        if not os.path.isfile(path):
                            logs.error(f"file {path} doesn't exists")
                            continue

                        if not os.access(path, os.X_OK):
                            logs.warning(f"file {path} is not executable")
                            os.chmod(path, 0o775)
                            logs.info(f"chmod +x {path}")

                        if field == "put":
                            flag = flags_storage.generate_flag()
                            result, err = check_exec(path, flag)
                            if err:
                                logs.error(f"{service.get('name')}-put-{i} cannot put flag")
                                result = None
                                if print_errors:
                                    print(err)
                            flags_storage.add_id_flag_pair(result, flag)

                        elif field == "check":
                            _id, flag = flags_storage.flags[-1]
                            if not _id:
                                logs.warning(f"{service.get('name')}-check-{i} skipped: put function is not working")
                                continue

                            result, err = check_exec(path, _id)
                            if err:
                                logs.error(f"{service.get('name')}-check-{i} script return error")
                                if print_errors:
                                    print(err)
                                continue

                            if result != flag:
                                logs.error(f"{service.get('name')}-check-{i} flags do not match")
                                if print_errors:
                                    logs.error(f"\t{result} != {flag}")
                                continue

                            logs.success(f"{service.get('name')}-{i} passed")


def check_exec(script_path, argument):
    p = subprocess.Popen(f'{script_path} localhost {argument}', shell=True, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if stderr == b'':
        stderr = None
    return stdout.decode().strip(), stderr


with open(file_name) as f:
    config = yaml.safe_load(f)

check_names(config, service_keys)
if check_name_flag:
    exit(1)

logs.success(f'[*] Fields in {file_name} checked successfully!')
check_executable(config)

# os.path.isfile()
# subprocess.run([])
# flags = [(1, 2), (3,4)] [*]
