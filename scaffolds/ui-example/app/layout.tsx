import React from "react";
import { AntdRegistry } from "@ant-design/nextjs-registry";
import { ConfigProvider } from "antd";
import { appTheme } from "@/theme/appTheme";

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <AntdRegistry>
          <ConfigProvider theme={appTheme}>{children}</ConfigProvider>
        </AntdRegistry>
      </body>
    </html>
  );
}
