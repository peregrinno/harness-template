import { test, expect } from "@playwright/test";

test("home shows platform health", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByText("Platform health")).toBeVisible();
  await expect(page.getByText("ui-example")).toBeVisible();
});
