import time


def main():
    try:
        while True:
            print("running")
            time.sleep(60)
    except KeyboardInterrupt:
        print("stopped")


if __name__ == '__main__':
    main()
