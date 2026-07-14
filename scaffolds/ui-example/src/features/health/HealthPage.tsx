import React from "react";
import { Layout } from "antd";
import { HealthPanel } from "@/components/organisms/HealthPanel";

const { Content } = Layout;

export function HealthPage() {
  return (
    <Layout style={{ minHeight: "100vh", padding: 24 }}>
      <Content>
        <HealthPanel />
      </Content>
    </Layout>
  );
}
