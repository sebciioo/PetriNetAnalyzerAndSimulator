from app import create_app
import threading

app = create_app()


def main():
    def run_server():
        app.run(host="0.0.0.0", port=5666, debug=False, use_reloader=False)

    thread = threading.Thread(target=run_server)
    thread.daemon = True
    thread.start()

