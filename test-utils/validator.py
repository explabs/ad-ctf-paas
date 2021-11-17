import subprocess
import os
import yaml
import uuid
import argparse


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
        self.cute_msg = False

    def success(self, *msg, **kwargs):
        print(*self.colored_msg(Colors.OKGREEN, *msg), **kwargs)

    def info(self, *msg, **kwargs):
        if self.cute_msg:
            print(*self.colored_msg(Colors.HEADER, *msg), **kwargs)
        else:
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
        self.env_folder = "admin-node/"
        self.env_file_name = ".env"

        self.api_folder = args.api
        self.api_config_name = self.api_folder + "config.yml"

        self.api_config = self.load_config(self.api_config_name)
        # TODO: validate config.yml fields
        self.service_names = list()
        self.mode = self.api_config["mode"]
        self.checker_config_name = self.api_folder + "checker.yml"
        self.checker_config = self.load_config(self.checker_config_name)

        if self.mode == args.mode:
            self.exploit_config_name = self.api_folder + "exploits.yml"
            self.exploit_config = self.load_config(self.exploit_config_name)

        self.scripts_dir = args.script

    @staticmethod
    def load_config(config_name):
        if not os.path.exists(config_name):
            logs.error(f"file {config_name} does not exists")
            exit(1)
        with open(config_name) as f:
            return yaml.safe_load(f)


class FieldsValidator(Validator):
    """
    # TODO: merge with ExecValidator
    Class for validate checker.yml correct syntax
    """

    def __init__(self):
        super().__init__()
        self.check_failed = False
        self.env_failed = False
        self.service_keys = [
            ["name", "cost", "hp", "put", "check"],
            ["name"]
        ]
        self.env_field = {"ADMIN_PASS", "SERVER_IP"}

    # TODO: after removing of "name" from exploits keys deprecate recursion
    def check_checker_file(self, data: dict, names: list):
        for field, data in data.items():
            for service in data:
                for key, values in service.items():
                    if key not in names[0]:
                        self.check_failed = True
                        logs.error(f'Unsupported key "{key}" for field "{field}"')
                    if isinstance(values, list):
                        self.check_checker_file({key: values}, names[1])

    def check_env(self):
        env_path = self.env_folder + self.env_file_name
        if not os.path.isfile(env_path):
            logs.error(f"file {env_path} doesn't exists")
            self.env_failed = True
        else:
            with open(env_path, 'r') as env:
                env_content = dict(
                    tuple(line.strip("\n").split('=')) for line in env.readlines()
                )
                if self.env_field != set(env_content.keys()):
                    print("error")

    def __call__(self):
        self.check_checker_file(self.checker_config, self.service_keys)
        self.check_env()


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
            print("  ", news_name)
            if args.news:
                with open(news_name) as n:
                    # TODO: (need to test) add cli Markdown output
                    print("  ", n.read())
        else:
            self.exploits_failed = True
            logs.error(f"file {path} does not exists")

    def __call__(self):
        self.run_exploits()


def main():
    # syntax validation
    logs.info("Config checking...")
    # TODO: write starts message before ALL validators
    fields_validation = FieldsValidator()
    fields_validation()
    if fields_validation.check_failed:
        # TODO: write message about fail for ALL validators error
        return 1
    logs.success(f'[*] Fields in config.yml checked successfully!')

    # checkers validation
    exec_validation = ExecuteValidator()
    exec_validation()
    if exec_validation.exec_failed:
        return 1
    logs.success(f'[*] All checkers run successfully!')

    # if mode is not "defence" exploits is not necessary
    if exec_validation.mode == args.mode:
        exploit_validation = ExploitsValidator()
        exploit_validation()
        if exploit_validation.exploits_failed:
            return 1
        logs.success(f'[*] All exploits run successfully!')
        # TODO: print services info (cost, hp etc)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Program for validation syntax and file existence")
    parser.add_argument('-d', '--dev', default=False, action='store_true',
                        help='dev mode for local tests (default: %(default)s)')
    parser.add_argument('-D', '--debug', default=False, action='store_true',
                        help='debug mod for errors showing (default: %(default)s)')
    parser.add_argument('-n', '--news', default=False, action='store_true',
                        help='print news from news file (default: %(default)s)')
    parser.add_argument('--api', default='admin-node/ad-ctf-paas-api/', type=str,
                        help='set api dir path if needed (default: %(default)s)')
    parser.add_argument('--script', default='admin-node/ad-ctf-paas-api/scripts/', type=str,
                        help='set script dir path if needed (default: %(default)s)')
    parser.add_argument('--mode', default='defence', choices=['defence', 'attack-defence', 'attack'], metavar='mode',
                        help='defines the game mode (default: %(default)s)', type=str)
    parser.add_argument('--girl', default=False, action='store_true',
                        help='makes info text a little bit cuter (default: %(default)s)')
    args = parser.parse_args()
    script_path = parser.get_default("script")
    api_path = parser.get_default("api")
    # if dev mode chosen change script path to current dir
    if args.dev:
        if args.script == script_path:
            args.script = "./"
        if args.api == api_path:
            args.api = "./"
    # TODO: write readme for validator and move script to admin-node or api
    # TODO: (maybe) run tasks with docker-compose
    logs = Logs()
    logs.debug_msg = args.debug
    logs.cute_msg = args.girl
    exit(main())
