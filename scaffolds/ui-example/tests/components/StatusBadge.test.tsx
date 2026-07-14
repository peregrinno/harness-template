import React from "react";
import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { StatusBadge } from "@/components/atoms/StatusBadge";

describe("<StatusBadge />", () => {
  it("should render the label", () => {
    render(<StatusBadge label="ok" tone="success" />);
    expect(screen.getByText("ok")).toBeInTheDocument();
  });
});
