import os

class Config(object):
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.getenv('DB_BIRTHDAY_URI')


class DevelopmentConfig(Config):
    DEBUG = True


class TestingConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False

app_config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
}
