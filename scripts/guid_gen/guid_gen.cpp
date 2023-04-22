#include <iostream>
#include <random>

std::string generate_guid() {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<unsigned int> dis(0, 255);

    // Generate 16 random bytes
    unsigned char bytes[16];
    for (int i = 0; i < 16; i++) {
        bytes[i] = static_cast<unsigned char>(dis(gen));
    }

    // Set version and variant fields of GUID
    bytes[6] &= 0x0f;  // Set version to 4
    bytes[8] &= 0x3f;  // Set variant to 10

    // Convert byte array to hex string
    const char* hex_chars = "0123456789abcdef";
    std::string guid;
    for (int i = 0; i < 16; i++) {
        guid += hex_chars[(bytes[i] >> 4) & 0x0f];
        guid += hex_chars[bytes[i] & 0x0f];
    }

    return guid;
}

int main() {
    std::string guid = generate_guid();
    std::cout << "Generated GUID: " << guid << std::endl;
    return 0;
}
