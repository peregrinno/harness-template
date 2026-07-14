import React from "react";
import { Typography } from "antd";

type StatusBadgeProps = {
  label: string;
  tone?: "success" | "default";
};

export function StatusBadge({ label, tone = "default" }: StatusBadgeProps) {
  const type = tone === "success" ? "success" : "secondary";
  return <Typography.Text type={type}>{label}</Typography.Text>;
}
