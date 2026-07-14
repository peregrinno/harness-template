import React from "react";
import { Card } from "antd";
import { HealthSummary } from "@/components/molecules/HealthSummary";

export function HealthPanel() {
  return (
    <Card title="Platform health">
      <HealthSummary serviceName="ui-example" status="ok" />
    </Card>
  );
}
