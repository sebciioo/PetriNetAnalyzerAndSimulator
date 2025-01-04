from flask import Flask


def create_app():
    """
    Tworzy instancję aplikacji Flask i konfiguruje ją.
    """
    app = Flask(__name__)
    app.config['DEBUG'] = False  #
    from .routes import bp as main_bp
    app.register_blueprint(main_bp)
    return app
