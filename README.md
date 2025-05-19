# BlackFang APT Repository

Welcome to the **BlackFang APT Repository** — a custom Debian-based package repository designed to host and distribute tools, scripts, and utilities maintained by the BlackFang team.

> ⚠️ **This repository is still under active development. Expect frequent changes, additions, and improvements. Use at your own discretion.**

---

## 📦 Available Packages

| Package       | Version | Description                                           |
|---------------|---------|-------------------------------------------------------|
| `fastportscan`| 1.0.0   | A high-speed, multithreaded port scanner built in Python | (testing package)

More packages will be added soon as development continues.

---

## 📥 How to Add This Repository

To use this repository on your Debian-based system:

1. Add the repository to your APT sources:

```bash
echo "deb [trusted=yes] https://kra1t0.github.io/blackfang-apt/ stable main" | sudo tee /etc/apt/sources.list```
