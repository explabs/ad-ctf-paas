import subprocess
import os
import yaml
import uuid


class Colors:
    """
    List of cli colors
    """
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
    """
    Colored prints for pretty output
    """

    def __init__(self):
        self.debug_msg = False

    def success(self, *msg, **kwargs):
        print(*self.colored_msg(Colors.OKGREEN, *msg), **kwargs)

    def info(self, *msg, **kwargs):
        print(*self.colored_msg(Colors.BOLD, *msg), **kwargs)

    def warning(self, *msg, **kwargs):
        print(*self.colored_msg(Colors.WARNING, *msg), **kwargs)

    def error(self, *msg, **kwargs):
        print(*self.colored_msg(Colors.FAIL, *msg), **kwargs)

    def debug(self, *msg, **kwargs):
        if self.debug_msg:
            print(*msg, **kwargs)

    @staticmethod
    def colored_msg(color, *msg):
        colored = list()
        for text in msg:
            colored.append(color + text + Colors.ENDC)
        return colored


class FlagsStorage:
    """
    Storage methods for emulate ad-api checker system
    """

    def __init__(self):
        self.flags = list()

    def add_id_flag_pair(self, _id, flag):
        self.flags.append((_id, flag))

    @staticmethod
    def generate_flag():
        return "test_" + uuid.uuid4().hex.upper()


class Validator:
    """
    Base Validator class for loads platform configs
    """

    def __init__(self):
        # TODO: check .env exists
        self.api_folder = "admin-node/ad-ctf-paas-api/"
        self.api_config_name = self.api_folder + "config.yml"
        self.api_config = self.load_config(self.api_config_name)
        # TODO: validate config.yml fields
        self.service_names = list()
        self.mode = self.api_config["mode"]
        self.checker_config_name = self.api_folder + "checker.yml"
        self.checker_config = self.load_config(self.checker_config_name)

        if self.mode == "defence":
            self.exploit_config_name = self.api_folder + "exploits.yml"
            self.exploit_config = self.load_config(self.exploit_config_name)

        self.scripts_dir = "admin-node/ad-ctf-paas-api/scripts/"

    @staticmethod
    def load_config(config_name):
        with open(config_name) as f:
            return yaml.safe_load(f)


class FieldsValidator(Validator):
    """
    Class for validate checker.yml correct syntax
    """

    def __init__(self):
        super().__init__()
        self.check_failed = False
        self.service_keys = [
            ["name", "cost", "hp", "put", "check"],
            ["name"]
        ]

    # TODO: after removing of "name" from exploits keys deprecate recursion
    def check_names(self, data: dict, names: list):
        for field, data in data.items():
            for service in data:
                for key, values in service.items():
                    if key not in names[0]:
                        self.check_failed = True
                        logs.error(f'Unsupported key "{key}" for field "{field}"')
                    if isinstance(values, list):
                        self.check_names({key: values}, names[1])

    def __call__(self):
        self.check_names(self.checker_config, self.service_keys)


def check_exec(script_path, argument):
    p = subprocess.Popen(f'{script_path} localhost {argument}', shell=True, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    stderr = stderr.decode()
    if stderr == "":
        stderr = None
    return stdout.decode().strip(), stderr


class ExecuteValidator(Validator):
    """
    Class for validate checkers scripts work
    """

    def __init__(self):
        super().__init__()
        self.executable_fields = ["put", "check"]
        self.exec_failed = False
        self.flags_storage = FlagsStorage()

    def check_executable(self):
        for service in self.checker_config["services"]:
            for field in self.executable_fields:
                script_path = service.get(field)
                if script_path is not None:
                    for i, file in enumerate(script_path, 1):
                        filename = file.get("name")
                        if filename is not None:
                            path = self.scripts_dir + filename
                            if not os.path.isfile(path):
                                logs.error(f"file {path} doesn't exists")
                                self.exec_failed = True
                                continue

                            if not os.access(path, os.X_OK):
                                logs.warning(f"file {path} is not executable")
                                os.chmod(path, 0o775)
                                logs.info(f"chmod +x {path}")

                            if field == "put":
                                flag = self.flags_storage.generate_flag()
                                result, err = check_exec(path, flag)
                                if err:
                                    logs.error(f"{service.get('name')}-put-{i} cannot put flag")
                                    logs.debug(err)
                                    result = None
                                self.flags_storage.add_id_flag_pair(result, flag)

                            elif field == "check":
                                _id, flag = self.flags_storage.flags[-1]
                                if not _id:
                                    logs.warning(
                                        f"{service.get('name')}-check-{i} skipped: put function is not working")
                                    self.exec_failed = True
                                    continue

                                result, err = check_exec(path, _id)
                                if err:
                                    logs.error(f"{service.get('name')}-check-{i} script return error")
                                    logs.debug(err)
                                    self.exec_failed = True
                                    continue

                                if result != flag:
                                    logs.error(f"{service.get('name')}-check-{i} flags do not match")
                                    logs.error(f"\t{result} != {flag}")
                                    self.exec_failed = True
                                    continue

                                logs.info(f"{service.get('name')}-{i} passed")

    def __call__(self):
        self.check_executable()


class ExploitsValidator(Validator):
    """
    Class for check exploits.yml config, and run rounds simulation with news and exploits
    """

    def __init__(self):
        super().__init__()
        self.news_path = ""
        self.exploits_failed = False

    def validate_syntax(self):
        # TODO: validate exploits.yml syntax (maybe)
        pass

    def run_exploits(self):
        for round_number, round_data in enumerate(self.exploit_config['rounds'], 1):
            logs.info(f"Round: {round_number}")
            for field, value in round_data.items():
                if field == "news":
                    self.print_news(value)
                elif field == "hint_news":
                    self.print_news(value)
                elif field == "exploits":
                    for exploit in value:
                        result, err = check_exec(self.scripts_dir + exploit["script_name"], "0")
                        if err:
                            self.exploits_failed = True
                            logs.error("  script error")
                            logs.debug(err)
                        elif result == '0':
                            logs.warning("  Exploitation failed: script returns 0")
                        elif result == '1':
                            logs.info("  Exploitation success")

    def print_news(self, news_name):
        path = self.news_path + news_name
        if os.path.exists(path):
            with open(news_name) as n:
                # TODO: (need to test) add cli Markdown output
                print("  ", news_name)
                print("  ", n.read())
        else:
            self.exploits_failed = True
            logs.error(f"file {path} does not exists")

    def __call__(self):
        self.run_exploits()


def main():
    # syntax validation
    logs.info("Config checking...")
    fields_validation = FieldsValidator()
    fields_validation()
    if fields_validation.check_failed:
        return 1
    logs.success(f'[*] Fields in config.yml checked successfully!')

    # checkers validation
    exec_validation = ExecuteValidator()
    exec_validation()
    if exec_validation.exec_failed:
        return 1
    logs.success(f'[*] All checkers run successfully!')

    # if mode is not "defence" exploits is not necessary
    if exec_validation.mode == "defence":
        exploit_validation = ExploitsValidator()
        exploit_validation()
        if exploit_validation.exploits_failed:
            return 1
        logs.success(f'[*] All exploits run successfully!')
    # TODO: print services info (cost, hp etc)


if __name__ == '__main__':
    # TODO: add argparse (debug mode, news print mode, default api and scripts path)
    # TODO: write readme for validator and move script to admin-node or api
    # TODO: (maybe) run tasks with docker-compose
    logs = Logs()
    logs.debug_msg = False
    exit(main())
