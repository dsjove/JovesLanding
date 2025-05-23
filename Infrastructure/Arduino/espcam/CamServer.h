#pragma once
#include <string>

class CamServer {
public:
  CamServer();

  bool begin(const char* name, const char* service = "http");

  std::string url() const { return _url; }

private:
  std::string _url;
};
