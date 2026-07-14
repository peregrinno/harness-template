import React from "react";
import { Space, Typography } from "antd";
import { StatusBadge } from "@/components/atoms/StatusBadge";

type HealthSummaryProps = {
  serviceName: string;
  status: string;
};

export function HealthSummary({ serviceName, status }: HealthSummaryProps) {
  return (
    <Space direction="vertical" size="small">
      <Typography.Title level={3}>{serviceName}</Typography.Title>
      <StatusBadge label={status} tone={status === "ok" ? "success" : "default"} />
    </Space>
  );
}
