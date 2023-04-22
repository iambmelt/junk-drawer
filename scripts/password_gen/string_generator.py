import itertools
import string

def generate_passwords(length):
    chars = string.ascii_letters + string.digits + string.punctuation
    for password in itertools.product(chars, repeat=length):
        yield ''.join(password)

if __name__ == '__main__':
    length = int(input("Enter password length: "))
    for password in generate_passwords(length):
        print(password)
